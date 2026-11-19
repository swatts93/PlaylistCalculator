package com.thelionsit.playlisttimer

import android.app.TimePickerDialog
import android.os.Bundle
import androidx.activity.ComponentActivity
import androidx.activity.compose.setContent
import androidx.activity.enableEdgeToEdge
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.foundation.lazy.items
import androidx.compose.foundation.text.KeyboardOptions
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.platform.LocalContext
import androidx.compose.ui.text.input.KeyboardType
import androidx.compose.ui.unit.dp
import androidx.lifecycle.compose.collectAsStateWithLifecycle
import androidx.lifecycle.viewmodel.compose.viewModel
import java.time.LocalDateTime
import java.time.LocalTime
import java.time.format.DateTimeFormatter

class MainActivity : ComponentActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        enableEdgeToEdge()
        setContent { MaterialTheme { Surface { App() } } }
    }
}

private val clock = DateTimeFormatter.ofPattern("h:mm a")

@Composable
fun App(vm: PlaylistViewModel = viewModel()) {
    val ui by vm.state.collectAsStateWithLifecycle()
    var showImport by remember { mutableStateOf(false) }
    val now = LocalDateTime.now()
    val start = ui.startTime?.let { now.toLocalDate().atTime(it) } ?: now
    val total = TimeCalculator.totalSeconds(ui.songs)

    LazyColumn(
        Modifier.fillMaxSize().safeDrawingPadding().padding(horizontal = 16.dp),
        verticalArrangement = Arrangement.spacedBy(12.dp),
    ) {
        item { Text("Playlist Time Calculator", style = MaterialTheme.typography.headlineSmall, modifier = Modifier.padding(top = 12.dp)) }

        item {
            Card(Modifier.fillMaxWidth()) {
                Column(Modifier.padding(16.dp), verticalArrangement = Arrangement.spacedBy(4.dp)) {
                    Text("Total duration", style = MaterialTheme.typography.labelLarge)
                    Text(TimeCalculator.format(total), style = MaterialTheme.typography.displaySmall)
                    Text("Ends at ${TimeCalculator.endTime(start, ui.songs)}" +
                        if (ui.startTime == null) " (starting now)" else " (starting ${ui.startTime!!.format(clock)})")
                    val selected = ui.songs.count { it.selected }
                    Text("$selected of ${ui.songs.size} songs selected · avg ${TimeCalculator.format(TimeCalculator.averageSeconds(ui.songs))}")
                    ui.targetTime?.let { t ->
                        val r = TimeCalculator.compareToTarget(ui.songs, t, now)
                        val d = TimeCalculator.format(r.differenceSeconds)
                        Text(
                            if (r.tooLong) "Over target ${t.format(clock)} by $d — remove songs"
                            else "$d to spare before ${t.format(clock)} — room for more",
                            color = if (r.tooLong) MaterialTheme.colorScheme.error else MaterialTheme.colorScheme.primary,
                        )
                    }
                }
            }
        }

        item {
            Row(horizontalArrangement = Arrangement.spacedBy(8.dp)) {
                TimeButton("Start", ui.startTime, "Now", vm::setStart)
                TimeButton("Target end", ui.targetTime, "Not set", vm::setTarget)
            }
        }

        item {
            Row(horizontalArrangement = Arrangement.spacedBy(8.dp)) {
                Button(onClick = vm::addSong) { Text("Add song") }
                OutlinedButton(onClick = { showImport = true }) { Text("Import") }
                TextButton(onClick = vm::clear) { Text("Clear") }
            }
        }

        items(ui.songs, key = { it.id }) { song -> SongRow(song, vm::update) { vm.removeSong(song.id) } }
        item { Spacer(Modifier.height(24.dp)) }
    }

    if (showImport) ImportDialog(onDismiss = { showImport = false }, onImport = { vm.importText(it) })
}

@Composable
private fun TimeButton(label: String, value: LocalTime?, empty: String, onSet: (LocalTime?) -> Unit) {
    val ctx = LocalContext.current
    OutlinedButton(onClick = {
        val v = value ?: LocalTime.now()
        TimePickerDialog(ctx, { _, h, m -> onSet(LocalTime.of(h, m)) }, v.hour, v.minute, false).show()
    }) { Text("$label: ${value?.format(clock) ?: empty}") }
    if (value != null) TextButton(onClick = { onSet(null) }) { Text("✕") }
}

@Composable
private fun SongRow(song: Song, onChange: (Song) -> Unit, onDelete: () -> Unit) {
    val invalid = song.duration.isNotBlank() && !song.hasValidDuration
    Card(Modifier.fillMaxWidth()) {
        Row(Modifier.padding(8.dp), verticalAlignment = Alignment.CenterVertically) {
            Checkbox(song.selected, { onChange(song.copy(selected = it)) })
            Column(Modifier.weight(1f), verticalArrangement = Arrangement.spacedBy(4.dp)) {
                OutlinedTextField(song.name, { onChange(song.copy(name = it)) }, label = { Text("Song") }, singleLine = true, modifier = Modifier.fillMaxWidth())
                Row(horizontalArrangement = Arrangement.spacedBy(8.dp)) {
                    OutlinedTextField(song.artist, { onChange(song.copy(artist = it)) }, label = { Text("Artist") }, singleLine = true, modifier = Modifier.weight(1f))
                    OutlinedTextField(
                        song.duration, { onChange(song.copy(duration = it)) },
                        label = { Text("m:ss") }, singleLine = true, isError = invalid,
                        keyboardOptions = KeyboardOptions(keyboardType = KeyboardType.Number),
                        modifier = Modifier.width(96.dp),
                    )
                }
            }
            TextButton(onClick = onDelete) { Text("Remove") }
        }
    }
}

@Composable
private fun ImportDialog(onDismiss: () -> Unit, onImport: (String) -> Int) {
    var text by remember { mutableStateOf("") }
    var message by remember { mutableStateOf<String?>(null) }
    AlertDialog(
        onDismissRequest = onDismiss,
        title = { Text("Import songs") },
        text = {
            Column {
                Text("One song per line, e.g. “Hotel California - Eagles 6:30”.")
                OutlinedTextField(text, { text = it }, modifier = Modifier.fillMaxWidth().height(180.dp))
                message?.let { Text(it, color = MaterialTheme.colorScheme.error) }
            }
        },
        confirmButton = {
            TextButton(onClick = {
                val n = onImport(text)
                if (n > 0) onDismiss() else message = "No songs with a m:ss duration found."
            }) { Text("Import") }
        },
        dismissButton = { TextButton(onClick = onDismiss) { Text("Cancel") } },
    )
}

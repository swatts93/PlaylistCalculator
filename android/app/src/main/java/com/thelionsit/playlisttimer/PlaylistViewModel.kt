package com.thelionsit.playlisttimer

import androidx.lifecycle.ViewModel
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.asStateFlow
import kotlinx.coroutines.flow.update
import java.time.LocalTime

data class UiState(
    val songs: List<Song> = listOf(Song(1)),
    val startTime: LocalTime? = null,   // null = start now
    val targetTime: LocalTime? = null,
)

class PlaylistViewModel : ViewModel() {
    private val _state = MutableStateFlow(UiState())
    val state: StateFlow<UiState> = _state.asStateFlow()
    private var nextId = 2L

    fun addSong() = _state.update { it.copy(songs = it.songs + Song(nextId++)) }
    fun removeSong(id: Long) = _state.update { s ->
        val left = s.songs.filterNot { it.id == id }
        s.copy(songs = left.ifEmpty { listOf(Song(nextId++)) })
    }
    fun update(song: Song) = _state.update { s -> s.copy(songs = s.songs.map { if (it.id == song.id) song else it }) }
    fun clear() = _state.update { it.copy(songs = listOf(Song(nextId++))) }
    fun setStart(t: LocalTime?) = _state.update { it.copy(startTime = t) }
    fun setTarget(t: LocalTime?) = _state.update { it.copy(targetTime = t) }

    fun importText(text: String): Int {
        val parsed = TimeCalculator.parseImport(text, nextId)
        nextId += parsed.size
        if (parsed.isNotEmpty()) _state.update { s ->
            val existing = s.songs.filter { it.name.isNotBlank() || it.duration.isNotBlank() }
            s.copy(songs = existing + parsed)
        }
        return parsed.size
    }
}

package com.thelionsit.playlisttimer

import java.time.Duration
import java.time.LocalDateTime
import java.time.LocalTime
import java.time.format.DateTimeFormatter

data class Song(
    val id: Long,
    val name: String = "",
    val artist: String = "",
    val duration: String = "",
    val selected: Boolean = true,
) {
    val seconds: Int get() = TimeCalculator.parseToSeconds(duration)
    val hasValidDuration: Boolean get() = seconds > 0
}

data class TargetResult(val differenceSeconds: Int, val tooLong: Boolean)

object TimeCalculator {
    private val timePattern = Regex("""^\d{1,2}:\d{2}(:\d{2})?$""")
    private val clockFormat: DateTimeFormatter = DateTimeFormatter.ofPattern("h:mm a")

    /** "MM:SS" or "H:MM:SS" -> seconds. Returns 0 for anything invalid. */
    fun parseToSeconds(text: String): Int {
        val t = text.trim()
        if (!timePattern.matches(t)) return 0
        val p = t.split(":").map { it.toInt() }
        return if (p.size == 2) p[0] * 60 + p[1] else p[0] * 3600 + p[1] * 60 + p[2]
    }

    fun format(totalSeconds: Int): String {
        val s = totalSeconds.coerceAtLeast(0)
        val h = s / 3600
        val m = (s % 3600) / 60
        val sec = s % 60
        return if (h > 0) "%d:%02d:%02d".format(h, m, sec) else "%d:%02d".format(m, sec)
    }

    fun totalSeconds(songs: List<Song>): Int = songs.filter { it.selected }.sumOf { it.seconds }

    fun averageSeconds(songs: List<Song>): Int {
        val valid = songs.filter { it.selected && it.hasValidDuration }
        return if (valid.isEmpty()) 0 else valid.sumOf { it.seconds } / valid.size
    }

    fun endTime(start: LocalDateTime, songs: List<Song>): String =
        start.plusSeconds(totalSeconds(songs).toLong()).format(clockFormat)

    /** Seconds from [now] until the next occurrence of [target] (tomorrow if already passed today). */
    fun secondsUntil(target: LocalTime, now: LocalDateTime): Int {
        var t = now.toLocalDate().atTime(target)
        if (t.isBefore(now)) t = t.plusDays(1)
        return Duration.between(now, t).seconds.toInt()
    }

    fun compareToTarget(songs: List<Song>, target: LocalTime, now: LocalDateTime): TargetResult {
        val playlist = totalSeconds(songs)
        val available = secondsUntil(target, now)
        return TargetResult(kotlin.math.abs(available - playlist), playlist > available)
    }

    /**
     * Parses pasted lines such as "Song - Artist 3:45", "Song, Artist, 3:45" or "Song 3:45".
     * Lines without a recognisable duration are skipped.
     */
    fun parseImport(text: String, firstId: Long): List<Song> {
        val dur = Regex("""(\d{1,2}:\d{2}(?::\d{2})?)""")
        var id = firstId
        return text.lineSequence().mapNotNull { raw ->
            val line = raw.trim()
            val m = dur.findAll(line).lastOrNull() ?: return@mapNotNull null
            val rest = (line.removeRange(m.range)).trim().trim('-', ',', '|', '\t', ' ')
            val parts = rest.split(Regex("""\s+-\s+|\s*[,|\t]\s*"""), limit = 2)
            Song(id++, name = parts[0].trim(), artist = parts.getOrElse(1) { "" }.trim(), duration = m.value)
        }.toList()
    }
}

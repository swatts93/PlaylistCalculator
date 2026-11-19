package com.thelionsit.playlisttimer

import org.junit.Assert.*
import org.junit.Test
import java.time.LocalDateTime
import java.time.LocalTime

class TimeCalculatorTest {
    @Test fun parses() {
        assertEquals(355, TimeCalculator.parseToSeconds("5:55"))
        assertEquals(3723, TimeCalculator.parseToSeconds("1:02:03"))
        assertEquals(0, TimeCalculator.parseToSeconds("abc"))
        assertEquals(0, TimeCalculator.parseToSeconds(""))
    }
    @Test fun formats() {
        assertEquals("5:55", TimeCalculator.format(355))
        assertEquals("1:02:03", TimeCalculator.format(3723))
    }
    @Test fun totalsOnlySelected() {
        val s = listOf(Song(1, duration = "3:00"), Song(2, duration = "2:00", selected = false))
        assertEquals(180, TimeCalculator.totalSeconds(s))
    }
    @Test fun targetWrapsToTomorrow() {
        val now = LocalDateTime.of(2026, 1, 1, 23, 0)
        assertEquals(2 * 3600, TimeCalculator.secondsUntil(LocalTime.of(1, 0), now))
    }
    @Test fun tooLong() {
        val now = LocalDateTime.of(2026, 1, 1, 12, 0)
        val r = TimeCalculator.compareToTarget(listOf(Song(1, duration = "1:30:00")), LocalTime.of(13, 0), now)
        assertTrue(r.tooLong); assertEquals(1800, r.differenceSeconds)
    }
    @Test fun imports() {
        val r = TimeCalculator.parseImport("Hotel California - Eagles 6:30\nBohemian Rhapsody, Queen, 5:55\nnoise", 1)
        assertEquals(2, r.size)
        assertEquals("Hotel California", r[0].name); assertEquals("Eagles", r[0].artist); assertEquals("6:30", r[0].duration)
        assertEquals("Queen", r[1].artist)
    }
}

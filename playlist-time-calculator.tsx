import React, { useState, useEffect } from 'react';
import { Plus, Minus, Clock, Target, Calculator, Upload, Download, ExternalLink } from 'lucide-react';

const PlaylistTimeCalculator = () => {
  const [songs, setSongs] = useState([{ id: 1, duration: '', name: '', artist: '', selected: true }]);
  const [totalTime, setTotalTime] = useState({ hours: 0, minutes: 0, seconds: 0 });
  const [startTime, setStartTime] = useState('');
  const [targetEndTime, setTargetEndTime] = useState('');
  const [results, setResults] = useState({});
  const [showImportModal, setShowImportModal] = useState(false);
  const [importText, setImportText] = useState('');

  // Convert time string (HH:MM:SS or MM:SS) to seconds
  const timeToSeconds = (timeStr) => {
    if (!timeStr) return 0;
    const parts = timeStr.split(':').map(Number);
    if (parts.length === 2) {
      return parts[0] * 60 + parts[1]; // MM:SS
    } else if (parts.length === 3) {
      return parts[0] * 3600 + parts[1] * 60 + parts[2]; // HH:MM:SS
    }
    return 0;
  };

  // Convert seconds to HH:MM:SS format
  const secondsToTime = (totalSeconds) => {
    const hours = Math.floor(totalSeconds / 3600);
    const minutes = Math.floor((totalSeconds % 3600) / 60);
    const seconds = totalSeconds % 60;
    
    if (hours > 0) {
      return `${hours}:${minutes.toString().padStart(2, '0')}:${seconds.toString().padStart(2, '0')}`;
    } else {
      return `${minutes}:${seconds.toString().padStart(2, '0')}`;
    }
  };

  // Add time to current time
  const addTimeToNow = (seconds) => {
    const now = new Date();
    const future = new Date(now.getTime() + seconds * 1000);
    return future.toLocaleTimeString();
  };

  // Add time to specific start time
  const addTimeToStart = (startTimeStr, seconds) => {
    if (!startTimeStr) return '';
    const [hours, minutes] = startTimeStr.split(':').map(Number);
    const startDate = new Date();
    startDate.setHours(hours, minutes, 0, 0);
    const endDate = new Date(startDate.getTime() + seconds * 1000);
    return endDate.toLocaleTimeString();
  };

  // Calculate time difference between two times
  const getTimeDifference = (time1Str, time2Str) => {
    const time1Seconds = timeToSeconds(time1Str);
    const time2Seconds = timeToSeconds(time2Str);
    return Math.abs(time2Seconds - time1Seconds);
  };

  // Parse imported playlist data
  const parseImportedData = (text) => {
    const lines = text.split('\n').filter(line => line.trim());
    const parsedSongs = [];
    
    // Try to detect format and parse accordingly
    lines.forEach((line, index) => {
      let name = '', artist = '', duration = '';
      
      // CSV format detection (common exports)
      if (line.includes(',')) {
        const parts = line.split(',').map(s => s.trim().replace(/"/g, ''));
        // Common CSV formats: "Name, Artist, Duration" or "Name, Artist, Album, Duration"
        if (parts.length >= 3) {
          name = parts[0];
          artist = parts[1];
          // Look for duration in format MM:SS or H:MM:SS
          const durationMatch = parts.find(part => /^\d{1,2}:\d{2}(:\d{2})?$/.test(part));
          duration = durationMatch || '';
        }
      }
      // Tab-separated or spaced format
      else if (line.includes('\t') || line.includes(' - ')) {
        const parts = line.split(/\t| - /).map(s => s.trim());
        if (parts.length >= 2) {
          name = parts[0];
          artist = parts[1];
          // Look for duration pattern
          const durationMatch = parts.find(part => /^\d{1,2}:\d{2}(:\d{2})?$/.test(part));
          duration = durationMatch || '';
        }
      }
      // Simple format: try to extract duration from anywhere in the line
      else {
        const durationMatch = line.match(/\d{1,2}:\d{2}(:\d{2})?/);
        duration = durationMatch ? durationMatch[0] : '';
        name = line.replace(/\d{1,2}:\d{2}(:\d{2})?/, '').trim();
      }
      
      if (name || duration) {
        parsedSongs.push({
          id: Date.now() + index,
          name: name || `Song ${index + 1}`,
          artist: artist || 'Unknown Artist',
          duration: duration,
          selected: true
        });
      }
    });
    
    return parsedSongs;
  };

  const handleImport = () => {
    if (importText.trim()) {
      const newSongs = parseImportedData(importText);
      if (newSongs.length > 0) {
        setSongs(newSongs);
        setImportText('');
        setShowImportModal(false);
      }
    }
  };
  useEffect(() => {
    // Calculate total duration
    const totalSeconds = songs.reduce((sum, song) => sum + timeToSeconds(song.duration), 0);
    setTotalTime({
      hours: Math.floor(totalSeconds / 3600),
      minutes: Math.floor((totalSeconds % 3600) / 60),
      seconds: totalSeconds % 60
    });

    // Calculate various scenarios
    const newResults = {
      totalDuration: secondsToTime(totalSeconds),
      endTimeFromNow: addTimeToNow(totalSeconds),
      endTimeFromStart: startTime ? addTimeToStart(startTime, totalSeconds) : '',
      timeUntilTarget: '',
      timeDifference: '',
      needsMoreTime: false,
      adjustmentNeeded: 0
    };

    // If target end time is set, calculate differences
    if (targetEndTime) {
      const currentTime = new Date();
      const targetTime = new Date();
      const [targetHours, targetMinutes] = targetEndTime.split(':').map(Number);
      targetTime.setHours(targetHours, targetMinutes, 0, 0);
      
      // If target time is earlier than now, assume it's tomorrow
      if (targetTime < currentTime) {
        targetTime.setDate(targetTime.getDate() + 1);
      }
      
      const timeUntilTargetSeconds = Math.floor((targetTime - currentTime) / 1000);
      newResults.timeUntilTarget = secondsToTime(timeUntilTargetSeconds);
      
      const difference = timeUntilTargetSeconds - totalSeconds;
      newResults.timeDifference = secondsToTime(Math.abs(difference));
      newResults.needsMoreTime = difference < 0;
      newResults.adjustmentNeeded = difference;
    }

    setResults(newResults);
  }, [songs, startTime, targetEndTime]);

  const addSong = () => {
    setSongs([...songs, { id: Date.now(), duration: '', name: '', artist: '', selected: true }]);
  };

  const removeSong = (id) => {
    setSongs(songs.filter(song => song.id !== id));
  };

  const updateSong = (id, field, value) => {
    setSongs(songs.map(song => 
      song.id === id ? { ...song, [field]: value } : song
    ));
  };

  const toggleSongSelection = (id) => {
    setSongs(songs.map(song => 
      song.id === id ? { ...song, selected: !song.selected } : song
    ));
  };

  return (
    <div className="max-w-4xl mx-auto p-6 bg-gradient-to-br from-blue-50 to-purple-50 min-h-screen">
      <h1 className="text-3xl font-bold text-center mb-8 text-gray-800 flex items-center justify-center gap-2">
        <Clock className="text-blue-600" />
        Playlist Time Calculator
      </h1>

      <div className="grid md:grid-cols-2 gap-6">
        {/* Input Section */}
        <div className="bg-white rounded-lg shadow-lg p-6">
          <div className="flex items-center justify-between mb-4">
            <h2 className="text-xl font-semibold text-gray-700 flex items-center gap-2">
              <Plus className="text-green-600" />
              Songs & Durations
            </h2>
            <div className="flex gap-2">
              <button
                onClick={() => setShowImportModal(true)}
                className="px-3 py-1 text-sm bg-blue-500 text-white rounded-md hover:bg-blue-600 transition-colors flex items-center gap-1"
              >
                <Upload size={14} />
                Import Playlist
              </button>
            </div>
          </div>

          {/* Import Instructions */}
          <div className="mb-4 p-3 bg-blue-50 rounded-lg text-sm text-blue-800">
            <div className="flex items-start gap-2">
              <ExternalLink size={16} className="mt-0.5 flex-shrink-0" />
              <div>
                <strong>Spotify Integration:</strong> Export your playlist using tools like Chosic.com (no login required) or Exportify.net, then paste the data here!
              </div>
            </div>
          </div>
          
          <div className="space-y-3 mb-4">
            {songs.map((song, index) => (
              <div key={song.id} className={`flex items-center gap-2 p-2 rounded-lg ${song.selected ? 'bg-white' : 'bg-gray-50'}`}>
                <input
                  type="checkbox"
                  checked={song.selected}
                  onChange={() => toggleSongSelection(song.id)}
                  className="w-4 h-4 text-blue-600"
                />
                <span className="text-sm text-gray-500 w-8">#{index + 1}</span>
                <div className="flex-1 grid grid-cols-3 gap-2">
                  <input
                    type="text"
                    placeholder="Song name"
                    value={song.name}
                    onChange={(e) => updateSong(song.id, 'name', e.target.value)}
                    className="px-2 py-1 text-sm border border-gray-300 rounded focus:outline-none focus:ring-1 focus:ring-blue-500"
                    disabled={!song.selected}
                  />
                  <input
                    type="text"
                    placeholder="Artist"
                    value={song.artist}
                    onChange={(e) => updateSong(song.id, 'artist', e.target.value)}
                    className="px-2 py-1 text-sm border border-gray-300 rounded focus:outline-none focus:ring-1 focus:ring-blue-500"
                    disabled={!song.selected}
                  />
                  <input
                    type="text"
                    placeholder="MM:SS"
                    value={song.duration}
                    onChange={(e) => updateSong(song.id, 'duration', e.target.value)}
                    className="px-2 py-1 text-sm border border-gray-300 rounded focus:outline-none focus:ring-1 focus:ring-blue-500"
                    disabled={!song.selected}
                  />
                </div>
                {songs.length > 1 && (
                  <button
                    onClick={() => removeSong(song.id)}
                    className="p-1 text-red-500 hover:bg-red-50 rounded"
                  >
                    <Minus size={14} />
                  </button>
                )}
              </div>
            ))}
          </div>

          <button
            onClick={addSong}
            className="w-full py-2 px-4 bg-green-500 text-white rounded-md hover:bg-green-600 transition-colors flex items-center justify-center gap-2"
          >
            <Plus size={16} />
            Add Song
          </button>

          <div className="mt-6 space-y-4">
            <div>
              <label className="block text-sm font-medium text-gray-700 mb-1">
                Start Time (optional)
              </label>
              <input
                type="time"
                value={startTime}
                onChange={(e) => setStartTime(e.target.value)}
                className="w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-blue-500"
              />
            </div>

            <div>
              <label className="block text-sm font-medium text-gray-700 mb-1">
                Target End Time
              </label>
              <input
                type="time"
                value={targetEndTime}
                onChange={(e) => setTargetEndTime(e.target.value)}
                className="w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-blue-500"
              />
            </div>
          </div>
        </div>

        {/* Results Section */}
        <div className="bg-white rounded-lg shadow-lg p-6">
          <h2 className="text-xl font-semibold mb-4 text-gray-700 flex items-center gap-2">
            <Calculator className="text-blue-600" />
            Results
          </h2>

          <div className="space-y-4">
            <div className="p-4 bg-blue-50 rounded-lg">
              <h3 className="font-semibold text-blue-800 mb-2">Total Playlist Duration</h3>
              <p className="text-2xl font-bold text-blue-600">{results.totalDuration}</p>
            </div>

            <div className="p-4 bg-green-50 rounded-lg">
              <h3 className="font-semibold text-green-800 mb-2">Will End At</h3>
              <p className="text-lg text-green-700">
                {results.endTimeFromStart || results.endTimeFromNow}
              </p>
              <p className="text-sm text-green-600">
                {results.endTimeFromStart ? 'From start time' : 'From now'}
              </p>
            </div>

            {results.timeUntilTarget && (
              <div className="p-4 bg-purple-50 rounded-lg">
                <h3 className="font-semibold text-purple-800 mb-2">Time Until Target</h3>
                <p className="text-lg text-purple-700">{results.timeUntilTarget}</p>
              </div>
            )}

            {results.timeDifference && (
              <div className={`p-4 rounded-lg ${results.needsMoreTime ? 'bg-red-50' : 'bg-yellow-50'}`}>
                <h3 className={`font-semibold mb-2 ${results.needsMoreTime ? 'text-red-800' : 'text-yellow-800'}`}>
                  <Target className="inline mr-1" size={16} />
                  Playlist vs Target Time
                </h3>
                <p className={`text-lg ${results.needsMoreTime ? 'text-red-700' : 'text-yellow-700'}`}>
                  {results.needsMoreTime ? 'Playlist is too long by: ' : 'You have extra time: '}
                  {results.timeDifference}
                </p>
                <p className={`text-sm mt-1 ${results.needsMoreTime ? 'text-red-600' : 'text-yellow-600'}`}>
                  {results.needsMoreTime 
                    ? 'Remove songs or shorten playlist' 
                    : 'You can add more songs'}
                </p>
              </div>
            )}

            {songs.some(song => song.duration) && (
              <div className="p-4 bg-gray-50 rounded-lg">
                <h3 className="font-semibold text-gray-800 mb-2">Quick Stats</h3>
                <div className="text-sm text-gray-600 space-y-1">
                  <p>Total songs: {songs.length} | Selected: {songs.filter(s => s.selected && s.duration).length}</p>
                  <p>Average song length: {songs.filter(song => song.selected && song.duration).length > 0 
                    ? secondsToTime(Math.floor(songs.filter(s => s.selected).reduce((sum, song) => sum + timeToSeconds(song.duration), 0) / songs.filter(song => song.selected && song.duration).length))
                    : '0:00'}</p>
                </div>
              </div>
            )}
          </div>
        </div>
      </div>

      {/* Import Modal */}
      {showImportModal && (
        <div className="fixed inset-0 bg-black bg-opacity-50 flex items-center justify-center z-50 p-4">
          <div className="bg-white rounded-lg shadow-xl max-w-2xl w-full max-h-[80vh] overflow-hidden">
            <div className="p-6 border-b">
              <h3 className="text-lg font-semibold text-gray-800">Import Playlist Data</h3>
              <p className="text-sm text-gray-600 mt-1">Paste your exported playlist data below</p>
            </div>
            
            <div className="p-6">
              <div className="mb-4">
                <h4 className="font-medium text-gray-700 mb-2">How to get your Spotify playlist data:</h4>
                <div className="text-sm text-gray-600 space-y-2">
                  <p><strong>Method 1:</strong> Visit <a href="https://www.chosic.com/spotify-playlist-exporter/" target="_blank" rel="noopener noreferrer" className="text-blue-600 hover:underline">Chosic.com</a> - No login required!</p>
                  <p><strong>Method 2:</strong> Use <a href="https://exportify.net/" target="_blank" rel="noopener noreferrer" className="text-blue-600 hover:underline">Exportify.net</a> - Export to CSV</p>
                  <p><strong>Method 3:</strong> Copy manually from Spotify (format: "Song Name - Artist MM:SS")</p>
                </div>
              </div>
              
              <textarea
                value={importText}
                onChange={(e) => setImportText(e.target.value)}
                placeholder="Paste your playlist data here...&#10;&#10;Supported formats:&#10;- CSV: Song Name, Artist, Duration&#10;- Text: Song Name - Artist MM:SS&#10;- Tab-separated data&#10;&#10;Example:&#10;Bohemian Rhapsody, Queen, 5:55&#10;Hotel California, Eagles, 6:30"
                className="w-full h-64 p-3 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-blue-500 text-sm font-mono"
              />
            </div>
            
            <div className="p-6 border-t flex justify-end gap-3">
              <button
                onClick={() => {setShowImportModal(false); setImportText('');}}
                className="px-4 py-2 text-gray-600 hover:bg-gray-100 rounded-md transition-colors"
              >
                Cancel
              </button>
              <button
                onClick={handleImport}
                className="px-4 py-2 bg-blue-500 text-white rounded-md hover:bg-blue-600 transition-colors"
                disabled={!importText.trim()}
              >
                Import Songs
              </button>
            </div>
          </div>
        </div>
      )}

      <div className="mt-6 text-center text-sm text-gray-500">
        <p>💡 Tip: Enter song durations in MM:SS format (e.g., 3:45) or HH:MM:SS for longer tracks</p>
      </div>
    </div>
  );
};

export default PlaylistTimeCalculator;
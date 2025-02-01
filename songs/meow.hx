//a

function onNoteCreation(e) {
    if (e.note.noteType == "TTS Hurt Note") e.note.kill();
}
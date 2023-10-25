/* TonePlayer.vala
 *
 * Copyright 2023 Diego Iván <diegoivan.mae@gmail.com>
 *
 * SPDX-License-Identifier: GPL-3.0-or-later
 */

[SingleInstance]
public class Flowtime.Services.TonePlayer : Object {
    private struct Sound {
        public string name;
        public File sound_file;
    }

    private HashTable<string, Sound?> tone_map;

    private unowned GLib.Application app = GLib.Application.get_default ();
    private Gtk.MediaFile? media_file = null;

    private TonePlayer? instance = null;
    public TonePlayer () {
        if (instance == null) {
            instance = this;
        }
    }

    construct {
        tone_map = new HashTable<string, Sound?> (string.hash, str_equal);

        register_sound ("Baum", "baum.ogg");
        register_sound ("Beep", "beep.ogg");
        register_sound ("Tone", "tone.ogg");
        register_sound ("Bleep", "bleep.ogg");

        var settings = new Settings ();
        swap_media_file (tone_map[settings.tone].sound_file);
    }

    public void register_sound (string name, string sound_file) {
        var file = File.new_for_uri (@"resource://$(app.resource_base_path)/$(sound_file)");
        var sound = Sound () {
            name = name,
            sound_file = file
        };
        tone_map[sound_file] = sound;
    }

    public void play_tone (string key)
    requires (key in tone_map) {
        unowned File sound = tone_map[key].sound_file;
        if (media_file != null && media_file.playing) {
            media_file.pause ();
        }
        swap_media_file (sound);
        media_file.play_now ();
    }

    private void swap_media_file (File new_file) {
        media_file?.close ();
        media_file = Gtk.MediaFile.for_file (new_file);
    }

    public List<unowned string> get_tone_keys () {
        return tone_map.get_keys ();
    }

    public string get_tone_name (string tone_key)
    requires (tone_key in tone_map) {
        return tone_map[tone_key].name;
    }
}

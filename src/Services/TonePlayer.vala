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
        public string sound_uri;
    }

    private HashTable<string, Sound?> tone_map;

    private unowned GLib.Application app = GLib.Application.get_default ();
    private Gst.Player player = new Gst.Player (null, null);

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
    }

    public void register_sound (string name, string sound_file) {
        var sound = Sound () {
            name = name,
            sound_uri = @"resource://$(app.resource_base_path)/$(sound_file)"
        };
        tone_map[sound_file] = sound;
    }

    public void play_tone (string key)
    requires (key in tone_map) {
        player.uri = tone_map[key].sound_uri;
        player.play ();
    }

    public List<unowned string> get_tone_keys () {
        return tone_map.get_keys ();
    }

    public string get_tone_name (string tone_key)
    requires (tone_key in tone_map) {
        return tone_map[tone_key].name;
    }
}

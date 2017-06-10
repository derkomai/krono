string run_command (string cmd) {
    int exit_status = -1;

    string std_out, std_err;

    try {
        Process.spawn_command_line_sync (cmd, out std_out,
                                              out std_err,
                                              out exit_status);

        if (exit_status != 0) {
            warning ("Error encountered while executing [" + cmd + "]:\n"+ std_err);
        }
    }
    catch (SpawnError e) {
        warning ("Error encountered while executing [" + cmd + "]:\n"+ std_err);
    }

    return std_out;
}


string namify (string str) {
    string result = "";

    foreach (string word in str.split(" ")) {
        result = result + " " + word[0].toupper ().to_string () + word.substring (1);
    }

    return result.strip ();
}


List<string> get_user_list () {
    List<string> users = new List<string> ();

    string output = run_command ("cat /etc/passwd");

    foreach (string line in output.split ("\n")) {
        if (line == "") continue;

        string[] fields = line.split (":");

        int userid = int.parse (fields[2]);

        if (userid >= 1000 && userid != 65534) {
            users.append (fields[0]);
        }
    }

    users.append("root");

    return users;
}


string gen_self_deleting_script (Task t, string user) {

    // Check for Krono directory
    string kronoDirName = "/home/" + user + "/" + KRONO_DIRNAME;

    if(!FileUtils.test (kronoDirName, FileTest.EXISTS)) {
        try {
            var kronoDir = File.new_for_path (kronoDirName);
            kronoDir.make_directory ();
        } catch (Error e) {
            stderr.printf ("%s\n", e.message);
        }
    }

    // Create script file name
    string code = t.cmd.hash ().to_string ();
    string fileName = kronoDirName + "/" + ONE_TIME_TAG + code + ".sh";

    // Check if script already exists
    if(FileUtils.test (fileName, FileTest.EXISTS)) {
        return fileName;
    }

    // Create script contents
    string script = SCRIPT_HEADER + "\n";

    script += "# This is a Krono self deleting script.\n";

    script += "# The associated cron job timing is: " + t.get_crontab_timing () + "\n\n";

    script += t.cmd + "\n";

    script += "crontab -u " + user + " -l | grep -v " + code + " > " + TMP_FILE + "\n";

    script += "crontab -u " + user + " " + TMP_FILE + "\n";

    script += "rm $(realpath \"$0\")\n";

    // Write script contents to file
    try {
        var file = File.new_for_path (fileName);

        var dos = new DataOutputStream (file.create (FileCreateFlags.REPLACE_DESTINATION));

        dos.put_string(script);
    } catch (Error e) {
        stderr.printf ("%s\n", e.message);
    }

    return fileName;
}

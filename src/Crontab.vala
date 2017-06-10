class Crontab
{
    // Properties

    public string user {
        get;
        private set;
    }

    public List<Task> tasks;

    // Constructors

    public Crontab (string _user = DEFAULT_USER) {
        string data;
        
        if (_user != DEFAULT_USER) {
            data = run_command ("sudo crontab -l -u " + _user);
            user = _user;
        } else {
            data = run_command ("crontab -l");
            user = run_command ("whoami").strip();
        }

        if (data == "no crontab for " + user) {
            return;
        }

        string[] lines = data.split ("\n");

        tasks = new List<Task> ();

        foreach (string line in lines) {
            // Discard empty lines
            if (line.strip () == "") {
                continue;
            }

            // Special lines
            bool inactive = line.contains (INACTIVE_TAG);
            bool one_time = line.contains (ONE_TIME_TAG);

            // Inactive task
            if (inactive) {
                tasks.append (new Task.from_crontab_line (line.substring (INACTIVE_TAG.length), inactive, one_time));
                continue;
            }

            // One-time task
            if (one_time) {
                tasks.append (new Task.from_crontab_line (line, inactive, one_time));
                continue;
            }

            // Generic task
            if (line[0] != '#') {
                tasks.append (new Task.from_crontab_line (line));
                continue;
            }
        }
    }

    // Methods

    public void addTask (string minute, string hour, string day_of_month, 
                         string month, string day_of_week, string cmd, bool active = true, bool one_time = false) {
        tasks.append (new Task (minute, hour, day_of_month, month, day_of_week, cmd, active, one_time));
    }

    public void addTaskFromLine (string crontab_line, bool active = true, bool one_time = false) {
        tasks.append (new Task.from_crontab_line (crontab_line, active, one_time));
    }

    public void addTaskFromPeriod (string period, string cmd) {
        tasks.append (new Task.from_period (period, cmd));
    }
    
    public void deleteTask (uint i) {
        tasks.remove (tasks.nth (i).data);
    }

    public void write() {
        try {
            var file = File.new_for_path (TMP_FILE);

            var dos = new DataOutputStream (file.create (FileCreateFlags.REPLACE_DESTINATION));

            dos.put_string (header);
            
            foreach (Task t in tasks) {
                string line = "";

                if (!t.active) {
                    line += INACTIVE_TAG;
                }

                if (t.num_format) {
                    line += (t.minute + " " + t.hour + " " + t.day_of_month + " " +
                             t.month + " " + t.day_of_week + " ");
                } else {
                    line += (t.period + " ");
                }

                if (t.one_time) {
                    line += ("sh " + gen_self_deleting_script (t, user));
                } else {
                    line += t.cmd;
                }

                dos.put_string (line + "\n");
            }

            //run_command ("crontab " + TMPFILE);
            run_command("mv " + TMP_FILE + " " + WRITTEN_FILE);
            
            file.delete ();
        } catch (Error e) {
            stderr.printf ("%s\n", e.message);
        }
    }

    string header = "# Edit this file to introduce tasks to be run by cron.\n
                 #\n
                 # Each task to run has to be defined through a single line\n
                 # indicating with different fields when the task will be run\n
                 # and what command to run for the task\n
                 #\n
                 # To define the time you can provide concrete values for\n
                 # minute (m), hour (h), day of month (dom), month (mon),\n
                 # and day of week (dow) or use '*' in these fields (for 'any').#\n
                 # Notice that tasks will be started based on the cron's system\n
                 # daemon's notion of time and timezones.\n
                 #\n
                 # Output of the crontab jobs (including errors) is sent through\n
                 # email to the user the crontab file belongs to (unless redirected).\n
                 #\n
                 # For example, you can run a backup of all your user accounts\n
                 # at 5 a.m every week with:\n
                 # 0 5 * * 1 tar -zcf /var/backups/home.tgz /home/\n
                 #\n
                 # For more information see the manual pages of crontab(5) and cron(8)\n
                 #\n
                 # m h  dom mon dow   command\n";

    public void show()
    {
        foreach (Task t in tasks) {
                stdout.printf ("%s\n", t.get_crontab_line ());
        }
    }
}
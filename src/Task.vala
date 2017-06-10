enum fieldType {ANY = 1, DEFINED = 2, RANGE = 3, SET = 4, RECURRENT = 5}

public const string dayNames[8] = {"Sunday", "Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday", "Sunday"};

public const string monthNames[12] = {"January", "February", "March", "April", "May", "June", "July", 
                                      "August", "September", "October", "November", "December"};

public const string dayNamesAbbreviated[8] = {"sun", "mon", "tue", "wed", "thu", "fri", "sat", "sun"};

public const string monthNamesAbbreviated[12] = {"jan", "feb", "mar", "apr", "may", "jun",
                                                 "jul", "aug", "sep", "oct", "nov", "dec"};

class Task {

    // Properties 
    
    public bool num_format {
        get;
        private set;
    }
    
    public string minute {     // (0-59)
        get;
        private set;
    }

    public string hour {       // (0-23)
        get;
        private set;
    }

    public string day_of_month { // (0-31)
        get;
        private set;
    }

    public string month {      // (1-12)
        get;
        private set;
    }

    public string day_of_week {  // (0-6)
        get;
        private set;
    }

    public string period {     // @reboot, @yearly, @annually, @monthly,
                               // @weekly, @daily, @midnight, @hourly
        get;
        private set;
    }

    public string cmd {
        get;
        private set;
    }

    public bool active {
        get;
        private set;
    }

    public bool one_time {
        get;
        private set;
    }

    // Constructors

    public Task (string _minute, string _hour, 
                 string _day_of_month, string _month, 
                 string _day_of_week, string _cmd,
                 bool _active = true, bool _one_time = false) {
        num_format = true;
        minute = _minute;
        hour = _hour;
        day_of_month = _day_of_month;
        month = _month;
        day_of_week = _day_of_week;
        cmd = _cmd;
        active = _active;
        one_time = _one_time;
    }

    public Task.from_period (string _period, string _cmd) {
        num_format = false;
        period = _period;
        cmd = _cmd;
        active = true;
        one_time = false;
    }

    public Task.from_crontab_line (string crontab_line, bool _active = true, bool _one_time = false) {
        string[] elements;

        if (crontab_line[0] == '@') {
            num_format = false;

            elements = crontab_line.split (" ", 2);

            period = elements[0];
            cmd    = elements[1];
        } else {
            num_format = true;

            elements = crontab_line.split (" ", 6);

            minute     = elements[0];
            hour       = elements[1];
            day_of_month = elements[2];
            month      = elements[3];
            day_of_week  = elements[4];
            cmd        = elements[5];
        }

        active = _active;
        one_time = _one_time;

        if (one_time) {
            //update cmd remove tag todo
        }
    }

    // Methods

    public string get_human_readable_timing () {
        string result = "";

        if (num_format) {

            //todo
            
        } else {
            if (period == "@reboot")                          {result += "every time the computer reboots.";         return result;}
            if (period == "@yearly" || period == "@annually") {result += "every year (1st of January at 0:00).";     return result;}
            if (period == "@monthly")                         {result += "every month (1st of the month at 0:00).";  return result;}
            if (period == "@weekly")                          {result += "every week (Sunday at 0:00).";             return result;}
            if (period == "@daily" || period == "@midnight")  {result += "every day (at 0:00).";                     return result;}
            if (period == "@hourly")                          {result += "every hour.";                              return result;}
        }

        return result;
    }

    public string get_crontab_timing () {
        if (num_format) {
            return minute + " " + hour + " " + day_of_month + " " + month + " " + day_of_week;
        } else {
            return period;
        }
    }

    public string get_crontab_line () {
        return get_crontab_timing () + " " + cmd;
    }

    fieldType get_field_type (string str) {
        if (str == "*")        return fieldType.ANY;
        if (str.contains ("-")) return fieldType.RANGE;
        if (str.contains (",")) return fieldType.SET;
        if (str.contains ("/")) return fieldType.RECURRENT;
        return fieldType.DEFINED;
    }

    public uint get_code () {
        uint code = 0;

        code += get_field_type (minute)       * 10000;
        code += get_field_type (hour)         * 1000;
        code += get_field_type (day_of_month) * 100;
        code += get_field_type (month)        * 10;
        code += get_field_type (day_of_week)  * 1;

        return code;
    }
}
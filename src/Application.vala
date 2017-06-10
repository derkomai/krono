/*
* Copyright (c) 2017 David Vilela
*
* This program is free software; you can redistribute it and/or
* modify it under the terms of the GNU General Public License 
* as published by the Free Software Foundation, either version 2 
* of the License, or (at your option) any later version.
*
* This program is distributed in the hope that it will be useful,
* but WITHOUT ANY WARRANTY; without even the implied warranty of
* MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the 
* GNU General Public License for more details.
*
* You should have received a copy of the GNU General Public License 
* along with this program; if not, see <http://www.gnu.org/licenses/>.
*/

public class Krono : Gtk.Application 
{
    bool adminPrivileges;

    public Krono () {
        Object(application_id: "com.github.derkomai.krono",
               flags: ApplicationFlags.FLAGS_NONE);
    }

    protected override void activate() {
        string user = run_command ("whoami").strip ();

        adminPrivileges = (user == "root");

        var app_window = new MainWindow (this);

		app_window.show_all();
    }

    public static int main(string[] args) {
        var app = new Krono();
        return app.run(args);
    }
}

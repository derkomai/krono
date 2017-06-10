public class MainWindow : Gtk.Window {
    public MainWindow (Gtk.Application application) {
        Object (
            application: application,
            title: "Krono",
            height_request: 750,
            width_request: 1000,
            icon_name: "com.github.derkomai.krono",
            resizable: true
        );
    }

    construct {
        Gtk.Label label = new Gtk.Label ("Krono test");
		add(label);
    }
}

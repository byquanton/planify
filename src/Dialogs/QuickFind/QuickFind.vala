/*
 * Copyright © 2023 Alain M. (https://github.com/alainm23/planify)
 *
 * This program is free software; you can redistribute it and/or
 * modify it under the terms of the GNU General Public
 * License as published by the Free Software Foundation; either
 * version 3 of the License, or (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
 * General Public License for more details.
 *
 * You should have received a copy of the GNU General Public
 * License along with this program; if not, write to the
 * Free Software Foundation, Inc., 51 Franklin Street, Fifth Floor,
 * Boston, MA 02110-1301 USA
 *
 * Authored by: Alain M. <alainmh23@gmail.com>
 */

public class Dialogs.QuickFind.QuickFind : Adw.Dialog {
    private Gtk.SearchEntry search_entry;
    private Gtk.ListView list_view;
    private ListStore list_store;
    private Gtk.SingleSelection selection_model;
    private Gtk.SignalListItemFactory list_item_factory;
    private Gtk.SignalListItemFactory header_factory;
    private Gtk.Stack stack;

    public QuickFind () {
        Object (
                content_width: 425,
                content_height: 350,
                presentation_mode: Adw.DialogPresentationMode.FLOATING
        );
    }

    ~QuickFind () {
        debug ("Destroying Dialogs.QuickFind.QuickFind\n");
    }

    construct {
        search_entry = new Gtk.SearchEntry () {
            placeholder_text = _ ("Quick Find"),
            hexpand = true,
            css_classes = { "border-radius-9" }
        };

        var cancel_button = new Gtk.Button.with_label (_ ("Cancel")) {
            css_classes = { "flat" }
        };

        var headerbar_box = new Gtk.Box (Gtk.Orientation.HORIZONTAL, 6) {
            hexpand = true,
            margin_top = 6,
            margin_bottom = 6,
            margin_start = 6
        };

        headerbar_box.append (search_entry);
        headerbar_box.append (cancel_button);

        var headerbar = new Adw.HeaderBar () {
            title_widget = headerbar_box,
            show_start_title_buttons = false,
            show_end_title_buttons = false,
            css_classes = { "flat" }
        };

        list_store = new GLib.ListStore (typeof (QuickFindItem));
        selection_model = new Gtk.SingleSelection (list_store);
        list_item_factory = new Gtk.SignalListItemFactory ();
        list_item_factory.setup.connect (QuickFindItem.on_list_item_setup);
        list_item_factory.bind.connect (QuickFindItem.on_list_item_bind);
        list_item_factory.unbind.connect (QuickFindItem.on_list_item_unbind);
        list_item_factory.teardown.connect (QuickFindItem.on_list_item_teardown);

        header_factory = new Gtk.SignalListItemFactory ();
        header_factory.setup.connect (QuickFindItem.on_header_setup);
        header_factory.bind.connect (QuickFindItem.on_header_bind);

        list_view = new Gtk.ListView (selection_model, list_item_factory) {
            hexpand = true,
            vexpand = true,
            margin_bottom = 6
        };
        list_view.header_factory = header_factory;

        var list_view_scrolled = new Gtk.ScrolledWindow () {
            hexpand = true,
            vexpand = true,
            hscrollbar_policy = Gtk.PolicyType.NEVER,
            child = list_view
        };

        stack = new Gtk.Stack ();
        stack.add_titled (get_placeholder (), "placeholder", "Placeholder");
        stack.add_titled (list_view_scrolled, "list", "List");

        var toolbar_view = new Adw.ToolbarView ();
        toolbar_view.add_top_bar (headerbar);
        toolbar_view.content = stack;

        child = toolbar_view;
        default_widget = search_entry;
        Services.EventBus.get_default ().disconnect_typing_accel ();

        search_entry.search_changed.connect (() => {
            search_changed ();
        });

        var list_view_controller_key = new Gtk.EventControllerKey ();
        list_view.add_controller (list_view_controller_key);
        list_view_controller_key.key_pressed.connect (key_pressed);

        var search_entry_ctrl_key = new Gtk.EventControllerKey ();
        search_entry.add_controller (search_entry_ctrl_key);
        search_entry_ctrl_key.key_pressed.connect ((keyval, keycode, state) => {
            var key = Gdk.keyval_name (keyval).replace ("KP_", "");

            if (keyval == Gdk.Key.Escape) {
                hide_destroy ();
            } else if (key == "Down") {
                list_view.grab_focus ();
                return true;
            }

            return false;
        });

        var event_controller_key = new Gtk.EventControllerKey ();
        ((Gtk.Widget) this).add_controller (event_controller_key);
        event_controller_key.key_pressed.connect ((keyval, keycode, state) => {
            if (keyval == Gdk.Key.Escape) {
                hide_destroy ();
            }

            return false;
        });

        cancel_button.clicked.connect (() => {
            hide_destroy ();
        });

        closed.connect (() => {
            Services.EventBus.get_default ().connect_typing_accel ();
        });
    }

    private bool key_pressed (uint keyval, uint keycode, Gdk.ModifierType state) {
        var key = Gdk.keyval_name (keyval).replace ("KP_", "");

        if (key == "Up") {
            var selected = selection_model.get_selected ();
            if (selected == 0) {
                search_entry.grab_focus ();
                search_entry.set_position (search_entry.text.length);
                return true;
            }
        } else if (key == "Down") {
        } else if (key == "Enter" || key == "Return" || key == "KP_Enter") {
            var selected_item = (Gtk.ListItem) selection_model.get_selected_item ();
            if (selected_item != null) {
                row_activated (selected_item);
            }
        } else if (key == "BackSpace") {
            if (!search_entry.has_focus && search_entry.text.length > 0) {
                search_entry.grab_focus ();
                int pos = search_entry.text.length;
                search_entry.delete_text (pos - 1, pos);
                search_entry.set_position (pos - 1);
                return true;
            }
        } else {
            if (!search_entry.has_focus) {
                unichar c = Gdk.keyval_to_unicode (keyval);
                if (c.isprint ()) {
                    search_entry.grab_focus ();
                    int pos = search_entry.text.length;
                    search_entry.insert_text (c.to_string (), -1, ref pos);
                    search_entry.set_position (pos);
                    return true;
                }
            }
        }

        return false;
    }

    private void search_changed () {
        if (search_entry.text.strip () != "") {
            search ();
        } else {
            clean_results ();
        }
    }

    private void search () {
        list_store.remove_all ();

        Objects.BaseObject[] filters = {
            Objects.Filters.Inbox.get_default (),
            Objects.Filters.Today.get_default (),
            Objects.Filters.Scheduled.get_default (),
            Objects.Filters.Pinboard.get_default (),
            Objects.Filters.Priority.high (),
            Objects.Filters.Priority.medium (),
            Objects.Filters.Priority.low (),
            Objects.Filters.Priority.none (),
            Objects.Filters.Labels.get_default (),
            Objects.Filters.Completed.get_default (),
            Objects.Filters.Tomorrow.get_default (),
            Objects.Filters.Anytime.get_default (),
            Objects.Filters.Repeating.get_default (),
            Objects.Filters.Unlabeled.get_default (),
            Objects.Filters.AllItems.get_default ()
        };

        foreach (var obj in filters) {
            if (search_entry.text.down () in obj.name.down () || search_entry.text.down () in obj.keywords.down ()) {
                var item = new QuickFindItem (obj, search_entry.text);
                list_store.append (item);
            }
        }

        foreach (var project in Services.Store.instance ().get_all_projects_by_search (search_entry.text)) {
            var item = new QuickFindItem (project, search_entry.text);
            list_store.append (item);
        }

        foreach (var section in Services.Store.instance ().get_all_sections_by_search (search_entry.text)) {
            var item = new QuickFindItem (section, search_entry.text);
            list_store.append (item);
        }

        foreach (var item_obj in Services.Store.instance ().get_all_items_by_search (search_entry.text)) {
            if (item_obj.project != null) {
                var item = new QuickFindItem (item_obj, search_entry.text);
                list_store.append (item);
            }
        }

        foreach (var label in Services.Store.instance ().get_all_labels_by_search (search_entry.text)) {
            var item = new QuickFindItem (label, search_entry.text);
            list_store.append (item);
        }

        // Switch to the list view if there are items
        if (list_store.get_n_items () > 0) {
            stack.set_visible_child_name ("list");
        } else {
            stack.set_visible_child_name ("placeholder");
        }
    }

    private void clean_results () {
        list_store.remove_all ();
        stack.set_visible_child_name ("placeholder");
    }

    private Gtk.Widget get_placeholder () {
        var message_label = new Gtk.Label (_ ("Quickly switch projects and views, find tasks, search by labels")) {
            wrap = true,
            justify = Gtk.Justification.CENTER,
            hexpand = true,
            vexpand = true,
            margin_top = 6,
            margin_start = 6,
            margin_end = 6,
            margin_bottom = 6
        };

        var placeholder_grid = new Gtk.Grid () {
            hexpand = true,
            vexpand = true,
            margin_top = 24,
            margin_start = 24,
            margin_end = 24,
            margin_bottom = 24
        };

        placeholder_grid.attach (message_label, 0, 0);

        return placeholder_grid;
    }

    private void row_activated (Gtk.ListItem list_item) {
        var item = (QuickFindItem) list_item.item;
        var base_object = item.base_object;

        if (base_object.object_type == ObjectType.PROJECT) {
            Services.EventBus.get_default ().pane_selected (PaneType.PROJECT, base_object.id_string);
        } else if (base_object.object_type == ObjectType.SECTION) {
            Services.EventBus.get_default ().pane_selected (PaneType.PROJECT,
                    ((Objects.Section) base_object).project_id.to_string ()
            );
        } else if (base_object.object_type == ObjectType.ITEM) {
            Services.EventBus.get_default ().pane_selected (PaneType.PROJECT,
                    ((Objects.Item) base_object).project_id.to_string ()
            );

            Timeout.add (275, () => {
                Services.EventBus.get_default ().open_item ((Objects.Item) base_object);
                return GLib.Source.REMOVE;
            });
        } else if (base_object.object_type == ObjectType.LABEL) {
            Services.EventBus.get_default ().pane_selected (PaneType.LABEL,
                    ((Objects.Label) base_object).id_string
            );
        } else if (base_object.object_type == ObjectType.FILTER) {
            Services.EventBus.get_default ().pane_selected (PaneType.FILTER, base_object.view_id);
        }

        hide_destroy ();
    }

    private void hide_destroy () {
        close ();
    }
}

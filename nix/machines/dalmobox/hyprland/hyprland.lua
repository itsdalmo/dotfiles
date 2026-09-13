-- Keep the entry point small: a failure in one module is easier to locate and
-- Hyprland reports the module name in its startup error.
require("config")
require("monitors")
require("bindings")

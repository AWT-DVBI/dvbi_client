{ pkgs, vscode, vscodeBaseDir, env }:


vscode.override {
  inherit vscodeBaseDir;
  nixExtensions = pkgs.vscode-utils.extensionsFromVscodeMarketplace [

    {
      name = "vscode-coverage-gutters";
      publisher = "ryanluker";
      version = "2.8.2";
      sha256 = "sha256-gMzFI0Z9b7I7MH9v/UC7dXCqllmXcqHVJU7xMozmMJc=";
    }
    {
      name = "flutter";
      publisher = "dart-code";
      version = "3.50.0";
      sha256 = "sha256-2Mi0BWXfO73BBIZIRJMaQyml+jXBI9d7By+vx9Rg+pE=";
    }
    {
      name = "dart-code";
      publisher = "dart-code";
      version = "3.50.0";
      sha256 = "sha256-vdECvW4BfuT3H6GD2cH7lVW0f5591pKjXsWyJzzpHYA=";
    }
  ] ++ (with pkgs.vscode-extensions;  [
    yzhang.markdown-all-in-one
    timonwong.shellcheck
    jnoortheen.nix-ide
    github.github-vscode-theme
  ]);
  settings = {
    "window.menuBarVisibility" = "toggle";
    "window.zoomLevel" = 0;
    "editor.fontSize" = 16;
    "terminal.integrated.fontSize" = 16;
    "lldb.displayFormat" = "hex";
    "breadcrumbs.enabled" = false;
    "files.associations" = {
      "*.s" = "asm-intel-x86-generic";
    };
    "editor.minimap.autohide" = true;
    "workbench.preferredDarkColorTheme" = "GitHub Dark";
    "workbench.preferredLightColorTheme" = "GitHub Light";
    "dart.checkForSdkUpdates" = false;
    "dart.flutterDaemonLogFile" = "${vscodeBaseDir}/daemon.log";
    "dart.flutterRunLogFile" =  "${vscodeBaseDir}/run-\${name}.log";
    "dart.flutterTestLogFile" = "${vscodeBaseDir}/test-\${name}.log";
    "dart.env" = env;
  };
}

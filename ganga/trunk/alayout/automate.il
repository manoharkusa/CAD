; === automate.il ===
; Calls your existing makeCalibreRunsetForCurrentCV() when CV changes
; and also writes a fixed runset: ~/calibre_runsets/nmlvs_current.rs
; (No change to your original function's logic.)

procedure( (writeCurrentRunsetFixed)
  let( (cv lib cell view user home root runRoot runsetDir runsetFile p)
    cv = geGetEditCellView()
    when(cv
      lib  = cv~>libName
      cell = cv~>cellName
      view = cv~>viewName
      user = or(getShellEnvVar("USER") "user")
      home = or(getShellEnvVar("HOME") "/tmp")
      root = getShellEnvVar("SCRATCH_ROOT")
      when(null(root) root = sprintf(nil "/scratch/%s" user))

      runRoot    = sprintf(nil "%s/calibre/%s/%s/%s" root lib cell view)
      runsetDir  = sprintf(nil "%s/calibre_runsets" home)
      runsetFile = sprintf(nil "%s/nmlvs_current.rs" runsetDir)

      when(procedurep('system)
        system(sprintf(nil "mkdir -p '%s' '%s'" runRoot runsetDir))
      )

      p = outfile(runsetFile)
      unless(p error(sprintf(nil "Cannot open %s for write" runsetFile)))

      fprintf(p, "// Auto-generated for %s/%s/%s\n" lib cell view)
      fprintf(p, "lvs.runDir.value = \"%s\"\n" runRoot)
      fprintf(p, "lvs.layout.topCellLibrary.value = \"%s\"\n" lib)
      fprintf(p, "cmn.layout.topCellLibraryFDI.value = \"%s\"\n" lib)
      fprintf(p, "lvs.layout.topCell.value = \"%s\"\n" cell)
      fprintf(p, "lvs.layout.topCellView.value = \"layout\"\n")
      fprintf(p, "cmn.layout.topCellViewFDI.value = \"layout\"\n")
      fprintf(p, "lvs.source2.topCellLibrary.value = \"%s\"\n" lib)
      fprintf(p, "lvs.source2.topCellLibraryFDI.value = \"%s\"\n" lib)
      fprintf(p, "lvs.source2.topCell.value = \"%s\"\n" cell)
      fprintf(p, "lvs.source2.topCellFDI.value = \"%s\"\n" cell)
      fprintf(p, "lvs.source2.topCellView.value = \"schematic\"\n")
      fprintf(p, "lvs.source2.topCellViewFDI.value = \"schematic\"\n")
      fprintf(p, "lvs.reports.lvsReport.value = \"%s.lvs.report\"\n" cell)
      close(p)

      printf("Fixed runset updated: %s\nRun dir: %s\n", runsetFile, runRoot)
    )
  )
)

_autoRunset_lastKey = nil
procedure( (autoRunsetTick)
  let( (cv k)
    cv = geGetEditCellView()
    k  = when(cv list(cv~>libName cv~>cellName cv~>viewName))
    when(k && k != _autoRunset_lastKey
      _autoRunset_lastKey = k
      makeCalibreRunsetForCurrentCV()   ; your original function (unchanged)
      writeCurrentRunsetFixed()         ; keep ~/calibre_runsets/nmlvs_current.rs synced
    )
  )
  hiRegTimer("autoRunsetTick()" 1)      ; integer seconds (NO decimals)
)
hiRegTimer("autoRunsetTick()" 1)        ; start the watcher


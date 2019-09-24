;;; Start Of READDRAFTSCR Function
(defun READDRAFTSCR (/ fn draftline)

 (setq scrpath (strcat(vl-registry-read "HKEY_LOCAL_MACHINE\\Software\\Siemens\\DesignTool\\Configuration" "Temp Folder" ) "\\draft.scr" ) )
 (setq fn (open  scrpath "r"))
  (if (/= fn nil)
    (progn
      (setq draftline (read-line fn))
      (while (/= draftline nil)
        (eval (read draftline))
        (princ)
        (setq draftline (read-line fn))
      ) ;end while
      (close fn)
    ) ;end progn
    (princ "\nDRAFT.SCR is not being used")
  ) ;end if
)
;;; End Of READDRAFTSCR Function

;;;  Start Up function for Autocad 2015
(defun s::startup()

	;;; Check the version of the AutoCAD. We only support AutoCAD 2015 ( i.e Version number 20.0 )
	;;; Only Load the .CUIX and ARX moudles if AutoCAD 2015 or Higher is installed
	(if (>= (atof (getvar 'AcadVer)) 20.0)
		(progn
			(setvar "MIRRTEXT" 0)                             ; Turn off the Mirror Text command off
			(setvar "MENUECHO" 0)                             ; Turn off the menu echo
			(setvar "CMDECHO" 0)                              ; Turn off the command echo
			(setvar "ATTREQ" 0)                               ; Turn off the attribute request
			(setvar "CELTYPE" "BYLAYER")                      ; Set Current Layer
			(setvar "CECOLOR" "BYLAYER")                      ; set Current Color
			(setvar "LTSCALE" 0.25)                           ; LineType Scale
			(setvar "LUPREC" 5)				    ; Linear unit precision
			(setvar "SNAPUNIT" (quote (0.03125 0.03125)))     ; Snap Units
			(setvar "GRIDUNIT" (quote (0.03125 0.03125)))     ; Grid Units
			(setvar "TEXTQLTY" 100)                           ; Text Qaulity
			(setvar "TEXTSTYLE" "STANDARD")                   ; Text Style
			(setvar "TEXTFILL" 1)                             ; Text Fill for TTF
			(setvar "TEXTSIZE" 0.09375)                       ; Default TEXTSIZE
			(setvar "ATTDIA" 0)                               ; Turn off the Attribute Dialog
			(setvar "ACADLSPASDOC" 1)                         ; Load acad.lsp into every drawing opened

			(menucmd "GACCOV.pop1=-")                      ; Unload the Image Menu from the MenuBar

			;This is to turn off the RegenAuto Dialog
			(setq regenVar (getvar "REGENMODE"))
			(if (= regenVar 0) (setvar "REGENMODE" 1) "")

			(setq todayVar (getvar "STARTUPTODAY"))
			(if (= todayVar 1) (setvar "STARTUPTODAY" 0) "")

			(command "_VIEWRES" "_Y" "20000")                 ; Make Sure Circles look like circles
			(readdraftscr)                                    ; Load the startup script
			(if (= (getvar "USERI1") 1)                       ; 0 = Mechsys, 1 = controller, 2 = Elec
				(progn
					(if (/= nil devname)
						(setvar "USERS5" devname)
					);end if
					(if (/= nil cecnam)
						(setvar "USERS5" cecnam)
					);end if
					(setvar "ATTREQ" 1)
				)
			)
			
			;(vl-file-delete "c:/temp/draft.scr")

			;;;l  Load the SBT Lisp Files

			(setq m1 (menugroup "SIEMENSSBT"));Make sure the menugroup definition is the same as within the mnu file!
			(if (/= m1 "SIEMENSSBT")
				(progn
					(if (and (= nil (findfile "SIEMENSSBT.cuix")))
						(princ "\nSIEMENSSBT menu not found. ")
					) ;end if
					;else
					(progn
						(command "menuload" (findfile "SIEMENSSBT.cuix"))
					) ;end progn
				) ;end progn
			) ;end if  

		  (menucmd "P11=+SIEMENSSBT.pop1"); Each pulldown menu
		  (princ "SIEMENSSBT partial menu has been loaded. ")

		  ;;;;  Load the SBT Arx files
		  (arxload "propertybrowser")
		  (arxload "cadutil")
		  (arxload "layout")
		  (arxload "layxfr")
		  (arxload "csal")
		  (arxload "sidebar")

		  ;;; Zoom the drawing 
		  (command "zoom" "extents")
		  (princ)
		);end progn
	);end if ( of AutoCAD Version checking )
 ) ; End of startup Function

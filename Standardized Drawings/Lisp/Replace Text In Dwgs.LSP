;;;CADALYST 04/05 Tip2028:  Replace Text In Dwgs.lsp      Adjust Text for All Drawings in a Directory (c) 2005 Andrzej Gumula 


;;;This tip code was updated May 3, 2005, to correct several bugs in the original version. 
;;;This new version also includes attribute options. 


;;; [c]2004 Andrzej Gumula, Katowice, Poland
;;; e-mail: a.gumula@wp.pl
;;; This routine replaces texts and optional also attributes in dwg files from the selected folder.
;;; Also accept subfolders.

(VL-LOAD-COM)
(defun c:Reid (/ Id Space Files ObjDbx DwgsList Chars Word SubDir Atrib LockedLayerList IdChange)
  
 (defun vl-get-LockedLayers (/ & Out)
  (vlax-for & (vla-get-Layers ObjDbx)
   (if (= :vlax-true (vlax-get-property & "Lock"))
    (setq Out (cons & Out))
   )
  )
  Out
 );end vl-get-LockedLayers

(defun GetFolder (Key / Dir Item Path)
 (cond
  ((setq Dir (vlax-invoke (vlax-get-or-create-object "Shell.Application") 'browseforfolder 0 "Select folder:" 1 ""))
   (cond
    ((not (vl-catch-all-error-p (vl-catch-all-apply 'vlax-invoke-method (list Dir 'Items))))
     (setq Item (vlax-invoke-method (vlax-invoke-method Dir 'Items) 'Item))
     (setq Path (vla-get-path Item))
     (if (not (member (substr Path (strlen Path) 1) (list "/" "\\")))
      (setq Path (strcat Path "\\"))
     );end if
    )
   );end cond
  )
 );end cond
 (if Dir (vlax-release-object Dir))
 (if Path (setq Path (vl-string-translate "/" "\\" Path)))
 (if Path (setq DwgPath Path))
 (CheckPath DwgPath Key)
);end GetFolder

 (defun CheckPath (Path Key)
  (if Path (setq Path (vl-string-translate "/" "\\" Path)))
  (if (not (member (substr Path (strlen Path) 1) (list "/" "\\")))
   (setq Path (strcat Path "\\"))
  );end if
  (set_tile "Path" Path)
  (if (and Path (vl-directory-files Path))
   (progn
    (set_tile "Message" "")
    (mode_tile "accept" 0)
    Path
   )
   (progn
    (set_tile "Message" "Uncorrect folder. ")
    (mode_tile "accept" 1)
    nil
    ;;(Correct Key "Uncorrect folder. ")
   )
  )
 );end CheckPath

(defun CheckText (Key Text)
 (if (or (if (= Key "OldText") (and Text (/= (vl-string-trim " " Text) "") (if (= Chars "0") (/= (strcase Text) (strcase NewText)) (/= Text NewText))))
	 (if (= Key "NewText") (if (= Chars "0") (/= (strcase Text) (strcase OldText)) (/= Text OldText)))
     )
  (progn
   (set_tile "error" "")
   (set_tile Key Text)
   Text
  )
  (Correct Key "Uncorrect pattern. ")
 )
);end CheckText

(defun CheckChars (Value)
  (setq Chars Value)
  (CheckText "OldText" OldText)
);end CheckChars

(defun Correct (Key Msg)
 (set_tile "error" Msg)
 (mode_tile Key 2)
 nil
);end Correct

(defun TxtSubst (A B C / Count)
  (setq Count 1)
  (while (/= "" (substr A Count 1))
    (if (equal (strcase B) (strcase (substr A Count (strlen B))))
      (setq A (strcat (substr a 1 (1- Count)) C (substr a (+ (strlen B) Count)))
	    Count (+ Count (strlen B)))
      (setq Count (1+ Count))
    );end if
  );end repeat
  A
);end TxtSubst

 (defun SubstrString (New Old Elem / Text)
   (vla-put-textstring Elem (TxtSubst (vla-get-textstring Elem) Old New))
   (setq IdChange T)
 );end SubstrString

(defun SearchString (Str Pat)
 (if (= Word "1")
  (or (= Str Pat) (wcmatch Str (strcat "* " Pat " *,* " Pat "," Pat " *")))	
  (wcmatch Str (strcat "*" Pat "*"))
 )
);end SearchString

  
(defun SearchSpace (Value Item)
 (vlax-for & (Value ObjDbx)
  (if (and (member (vla-get-ObjectName &) '("AcDbText" "AcDbMText"))
	   (if (= Chars "1") (SearchString (vla-get-TextString &) OldText)
                             (SearchString (strcase (vla-get-TextString &)) (strcase OldText))))
   (progn
   (setq IdChange T)
   (SubstrString NewText OldText &)
   )
  );end if
  (if (and (= Atrib "1")
	   (member (vla-get-ObjectName &) '("AcDbBlockReference"))
	   (= (vla-get-HasAttributes &) :vlax-true))
    (progn
     (foreach % (vlax-invoke & 'GetAttributes)
       (if (if (= Chars "1") (SearchString (vla-get-TextString %) OldText)
                             (SearchString (strcase (vla-get-TextString %)) (strcase OldText)))
        (progn
         (setq IdChange T)
         (SubstrString NewText OldText %)
        )
       );end if
     );end foreach
    )
  );end if
 );end vlax
);end SearchSpace

(defun Help_Ftid (/ Tmp)
 (if (not (new_dialog "help" Id)) (exit))
 (setq Tmp (list "This routine replace text in dwg files from the selected folder."
		 "Options:"
		 "-match case: allow for uppercase and lowercase alphabetic characters"
		 "-find whole words only: if active the routine analyse only whole words"
		 "-find in subfolder: if active the routine find dwg files also in subfolders of selected folder"
		 "-model space: if active the routine analize text entities only in model space"
		 "-paper space: if active the routine analize text entities only in paper space (layouts)"
		 "-both space: if active the routine analize text entities only in model and paper spaces"
                 "Version 1.0a"
                 "Written by Andrzej GUMULA, Katowice, Poland"
                 "e-mail: a.gumula@wp.pl"))
 (start_list "lista")
 (mapcar 'add_list Tmp)
 (end_list)
 (action_tile "accept" "(done_dialog 1)")
 (start_dialog)
);end Help_Ftid


(defun vl-findfile (Location / DirList Path AllPath)
 (MakeDirList Location)
 (setq DirList (cons Location DirList))
 (foreach Elem DirList 
  (if (setq Path (vl-directory-files Elem "*.dwg"))
   (foreach Item Path (setq AllPath (cons (strcat Elem "\\" Item)  AllPath)))
  );end if
 )
 (reverse AllPath)
);end vl-findfile

(defun MakeDirList (Arg / TmpList)
 (setq TmpList (vl-remove "System Volume Information" (vl-remove "RECYCLER" (vl-remove ".." (vl-remove "." (vl-directory-files Arg nil -1))))))
 (cond
  (TmpList
   (setq DirList (append DirList (mapcar '(lambda (z) (strcat Arg "\\" z)) TmpList)))
   (foreach Item TmpList (MakeDirList (strcat Arg "\\" Item)))
  )
 );end cond
);end MakeDirList

(if (> (atoi (getvar "AcadVer")) 15)
 (setq ObjDbx (vla-GetInterfaceObject (vlax-get-acad-object) "ObjectDBX.AxDbDocument.18"))
 (cond
   ((not (vl-catch-all-error-p (vl-catch-all-apply 'vla-getInterfaceObject (list (vlax-get-acad-object) "ObjectDBX.AxDbDocument"))))
    (startapp "regsvr32.exe /s axdb15.dll")
    (setq ObjDbx (vla-getInterfaceObject (vlax-get-acad-object) "ObjectDBX.AxDbDocument"))
   )
 );end cond
);end if
(setq FileSystemObject (vla-getInterfaceObject (vlax-get-acad-object) "Scripting.FileSystemObject"))


(vl-load-com)
(setq Id (load_dialog "Replace Text In Dwgs"))
(if (not (new_dialog "ftid" Id)) (exit))
(if DwgPath (set_tile "Path" DwgPath) (set_tile "Path" (setq DwgPath (getvar "dwgprefix"))))
(if (= (type OldText) 'STR) (set_tile "OldText" OldText) (set_tile "OldText" (setq OldText "Bentley")))
(if (= (type NewText) 'STR) (set_tile "NewText" NewText) (set_tile "NewText" (setq NewText "Autodesk")))
(if (not (setq Files (vl-directory-files DwgPath "*.dwg" 1))) (CheckPath DwgPath "Path"))
(setq Space 1)
(set_tile "MSpace" "1")
(set_tile "error" "")
(setq Chars "0")
(action_tile "Button" "(GetFolder $key)")
(action_tile "Path" "(setq DwgPath (CheckPath (get_tile $key) $key))")
(action_tile "OldText"  "(setq OldText (CheckText $key (get_tile $key)))")
(action_tile "NewText"  "(setq NewText (CheckText $key (get_tile $key)))")
(action_tile "Chars"  "(CheckChars (get_tile $key)))")
(action_tile "Word"  "(setq Word (get_tile $key)))")
(action_tile "Subdir"  "(setq SubDir (get_tile $key)))")
(action_tile "Atrib"  "(setq Atrib (get_tile $key)))")
(action_tile "MSpace"  "(setq Space 1)")
(action_tile "PSpace"  "(setq Space 2)")
(action_tile "Both"  "(setq Space 3)")
(action_tile "accept" "(done_dialog 1)")
(action_tile "cancel" "(done_dialog 0)")
(action_tile "help" "(Help_Ftid)")
(if (= (start_dialog) 1)
 (progn
 (if (= SubDir "1")
   (setq Files (vl-findfile (substr DwgPath 1 (1- (strlen DwgPath)))))
   (setq Files (mapcar '(lambda (x) (strcat Dwgpath x)) (vl-directory-files DwgPath "*.dwg" 1)))
 );end if
 (if (not (member (substr DwgPath (strlen DwgPath) 1) (list "/" "\\")))
  (setq DwgPath (strcat DwgPath "\\"))
 );end if
 (if Files
   (princ "\nLooking for text to replace. Please wait...\n")
   (princ "\nDwg files were not found. ")
 );end if
 (foreach Item Files
  (cond
   ((not (vl-catch-all-error-p (vl-catch-all-apply 'vla-open (list ObjDbx Item))))
   (cond
    ((/= (logand (vlax-get-property (vlax-invoke-method FileSystemObject 'GetFile Item) 'Attributes) 1) 1)
     (if (setq LockedLayerList (vl-get-LockedLayers))
      (foreach & LockedLayerList (vla-put-lock & :vlax-false))
     );end if
     (princ (strcat "\nOpen " Item))
     (if (= (logand 1 Space) 1) (SearchSpace vla-get-ModelSpace Item))
     (if (= (logand 2 Space) 2) (SearchSpace vla-get-PaperSpace Item))
     (if LockedLayerList (foreach & LockedLayerList (vla-put-lock & :vlax-true)))
     (setq LockedLayerList nil)
     (if IdChange 
      (progn
       (prompt (strcat "\nOccurrence was found in " Item))
       (vla-saveas ObjDbx Item)
       (prompt "\nDrawing was modified and saved. ")
      )
      (prompt (strcat "\nNo more occurrences found in " Item))
     );end if
     (setq IdChange nil)
    )
    (T (prompt (strcat (if (= SubDir "1") Item (strcat DwgPath Item)) " is read-only. Cannot modify.")))
   );end cond
   )
   (T (prompt (strcat "\nCannot find in " Item ". Probably drawing is open now. ")))
  );end cond
 );end foreach
 (mapcar 'vlax-release-object (list ObjDbx FileSystemObject))
 )
);end if
(unload_dialog Id)
(princ)
);end file

(prompt "\nLoaded new command Reid. ")
(prompt "\n[c]2004 Andrzej Gumula. ")
(princ)



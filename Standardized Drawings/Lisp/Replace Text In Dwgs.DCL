help:dialog{
label="HELP AND INFO";
:list_box{
tabs="3"; 
key="lista";
width=75;
fixed_width=true;
height=15;
fixed_height=true;}
ok_only;}


ftid:dialog{
label="REPLACE TEXT IN DWG FILES";

:boxed_column{
label="Folder with dwg files:";
:row{
fixed_width=true;
:button{
key="Button";
label="Select>";
mnemonic=S;
width=7;}
:edit_box{
key="Path";
label="";
mnemonic=P;
edit_width=35;}
          }
:text{
key="Message";
width=43;
fixed_width=true;}
      }
:row{
:column{
fixed_height = true;
fixed_width = true;
:edit_box{
key="OldText";
label="Find:";
mnemonic=F;
edit_width=15;
         }
:edit_box{
key="NewText";
label="Replace with:";
mnemonic=R;
edit_width=15;
         }         
:toggle{
key="Chars";
alignment=left;
mnemonic=C;
label="match Case?";}
:toggle{
key="Word";
alignment=left;
mnemonic=W;
label="find whole Words only?";}
:toggle{
key="Subdir";
alignment=left;
mnemonic=u;
label="find in Subfolders?";}
:toggle{
key="Atrib";
alignment=left;
mnemonic=A;
label="find in Attributes?";}
}
:radio_column{
label="Space of searches: ";
width=15;
//fixed_width=true;

//fixed_width=true;
:radio_button{
label="Model space";
width=10;
key="MSpace";
mnemonic=M;
}
:radio_button{
label="Paper space";
width=10;
key="PSpace";
mnemonic=P;
}
:radio_button{
width=10;
label="Both spaces";
key="Both";
mnemonic=B;
}

}
}
spacer_1;
ok_cancel_help_errtile;}
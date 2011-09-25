/obj/admins/proc/DisplayMenu(var/mob/user)
	var/txt = {"<HTML><HEAD><TITLE>Spawn Object</TITLE></HEAD><BODY>
				<FORM NAME="Spawner" ACTION="?src=\ref[src]" METHOD="GET">
				Type  <INPUT TYPE="text" NAME="SearchBar" VALUE="" onKeyUp="updateSearch()" onKeyPress="submitFirst(event)" style="width:350px"><BR>
				Offset: <INPUT TYPE="text" NAME="offset" VALUE="x,y,z" style="width:250px">
				A <INPUT TYPE="radio" NAME="otype" VALUE="absolute">
				R <INPUT TYPE="radio" NAME="otype" VALUE="relative" checked="checked"><BR>
				Number: <INPUT TYPE="text" NAME="number"  VALUE="1" style="width:330px"><BR><BR>
				<SELECT NAME="ObjectList" id="ObjectList" size="20" multiple style="width:400px"></SELECT><BR>
				<INPUT TYPE="hidden" name="src" value="\ref[src]">
				<INPUT TYPE="submit" value="spawn">
				</FORM>

				<SCRIPT LANGUAGE="JavaScript">
					var OldSearch = "";
					var ObjectList = document.Spawner.ObjectList;
					var ObjectTypes = "[dd_list2text(typesof(/obj),";")]";
					var ObjectArray = ObjectTypes.split(";");
					document.Spawner.SearchBar.focus();
					populateList();

					function populateList()
					{
						var myElem;
						ObjectList.options.length = 0;
						for(myElem in ObjectArray)
						{
							var oOption = document.createElement("OPTION");
							oOption.value = ObjectArray\[myElem\];
							oOption.text = ObjectArray\[myElem\];
							ObjectList.options.add(oOption);
						}
					}
					function updateSearch()
					{
						if(OldSearch == document.Spawner.SearchBar.value) return;
						OldSearch = document.Spawner.SearchBar.value;
						ObjectArray = new Array();

						var TestElem;
						var TmpArray = ObjectTypes.split(";");
						for(TestElem in TmpArray)
						{
							if(TmpArray\[TestElem\].search(OldSearch) < 0) continue;
							ObjectArray.push(TmpArray\[TestElem\]);
						}
						populateList();
					}
					function submitFirst(event)
					{
						if(!ObjectList.options.length) return false;
						if(event.keyCode == 13 || event.which == 13)
							ObjectList.options\[0\].selected = 'true';
					}
				</SCRIPT></BODY></HTML>"}
	user << browse(txt, "window=create_object;size=425x475")

extends window
export(PackedScene) var filter
export(PackedScene) var folder
enum FILEPOS{
	USER
	EXECUTABLE
	RES
}
export(FILEPOS) var save_folder
var defaulttree=[
		#subroot, contains root and its never opened.
		{"origin":-1,
		"enabled":true,
		"inside":
			[
				{
				"type":"folder",
				"name":"root",
				"enabled":true,
				"index":1
				}
			]
		},
		#root, the folder read by default.
		{
		"origin":0,
		"enabled":true,
		"inside":[]
		}
	]
var filtertree:Array=defaulttree
var verbs:Array=[]
var fileman=File.new()
var filedir
var index=1
onready var box=$scroll/vbox


func _ready():
	globals.library=self
	match save_folder:
		FILEPOS.EXECUTABLE:
			filedir=OS.get_executable_path()+"/filters.json"
		FILEPOS.USER:
			filedir="user://filters.json"
		FILEPOS.RES:
			filedir="res://filters.json"
	openfilters()


func deleteall():
	filtertree=defaulttree


func openfilters():
	deleteall()
	var error=fileman.open(filedir,File.READ)
	if error==OK:
		if fileman.get_as_text()!="":
			var dict=JSON.parse(fileman.get_as_text())
			if dict.error==OK:
				filtertree=dict.result[0] as Array
				verbs=dict.result[1]
				box.openfolder(1)
			else:
				globals.popuper.popup("error abriendo los filtros","error "+str(dict.error)+"en la linea "+str(dict.error_line))
		else:
			print("empty file.")
			box.openfolder(1)
		fileman.close()
	else:
		globals.popuper.popup("error abriendo el archivo","error "+str(error))


func savefilters():
	box.savecurrent()
	var error=fileman.open(filedir,File.WRITE)
	if error==OK:
		fileman.store_string(JSON.print([filtertree,verbs],"\t"))
		fileman.close()
	else:
		globals.popuper.popup("error guardando!","error "+str(error))

func _on_newfilter_pressed():
	addelement(filter.instance())


func _on_save_pressed():
	savefilters()
	globals.popuper.popup("guardado!")

func _notification(what):
	if what==MainLoop.NOTIFICATION_WM_QUIT_REQUEST:
		savefilters()

func addelement(new:libraryelement):
	new.index=filtertree[index]["inside"].size()
	box.add_child(new)
	var data:Dictionary
	if new.has_method("getdef"):
		data=new.getonnew()
	else:
		data=new.getsavedata()
	filtertree[index]["inside"].append(data)


func _on_newfolder_pressed():
	addelement(folder.instance())


func _on_folderup_pressed():
	box.savecurrent()
	if index==1:return
	box.openfolder(filtertree[index]["origin"])
	var text=$dir.text
	$dir.text=stringfunc.cutright(text.find_last("/"),text)


func _on_excludequotes_toggled(button_pressed):
	globals.skipquotes=button_pressed


#blueprints
func _on_blueprint_pressed():
	$blueprints.visible=true
	editing=null


var editing=null
export(PackedScene) var blueprint


func _on_blueprints_save(dict):
	if editing==null :
		var new=blueprint.instance() as libraryelement
		addelement(new)
		new.fromfile(dict)
	else:
		editing.code=dict["code"]

func editblue(who:libraryelement):
	editing=who
	$blueprints.visible=true
	$blueprints.addcode(who.code)

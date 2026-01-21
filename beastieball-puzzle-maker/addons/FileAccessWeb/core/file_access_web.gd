class_name FileAccessWeb
extends RefCounted

signal load_started(file_name: String)
signal loaded(file_name: String, file_type: String, base64_data: String)
signal progress(current_bytes: int, total_bytes: int)
signal error()
signal upload_cancelled()

var _file_uploading: JavaScriptObject

var _on_file_load_start_callback: JavaScriptObject
var _on_file_loaded_callback: JavaScriptObject
var _on_file_progress_callback: JavaScriptObject
var _on_file_error_callback: JavaScriptObject
var _on_file_cancelled_callback: JavaScriptObject

func _init() -> void:
	if _is_not_web():
		_notify_error()
		return

	JavaScriptBridge.eval(js_source_code, true)
	_file_uploading = JavaScriptBridge.get_interface("godotFileAccessWeb")

	_on_file_load_start_callback = JavaScriptBridge.create_callback(_on_file_load_start)
	_on_file_loaded_callback = JavaScriptBridge.create_callback(_on_file_loaded)
	_on_file_progress_callback = JavaScriptBridge.create_callback(_on_file_progress)
	_on_file_error_callback = JavaScriptBridge.create_callback(_on_file_error)
	_on_file_cancelled_callback = JavaScriptBridge.create_callback(_on_file_cancelled)

	_file_uploading.setLoadStartCallback(_on_file_load_start_callback)
	_file_uploading.setLoadedCallback(_on_file_loaded_callback)
	_file_uploading.setProgressCallback(_on_file_progress_callback)
	_file_uploading.setErrorCallback(_on_file_error_callback)
	_file_uploading.setCancelledCallback(_on_file_cancelled_callback)

func open(accept_files: String = "*") -> void:
	if _is_not_web():
		_notify_error()
		return

	_file_uploading.setAcceptFiles(accept_files)
	_file_uploading.open()

func _is_not_web() -> bool:
	return OS.get_name() != "Web"

func _notify_error() -> void:
	push_error("File Access Web worked only for HTML5 platform export!")

func _on_file_load_start(args: Array) -> void:
	var file_name: String = args[0]
	load_started.emit(file_name)

func _on_file_loaded(args: Array) -> void:
	var file_name: String = args[0]
	var splitted_args: PackedStringArray = args[1].split(",", true, 1)
	var file_type: String = splitted_args[0].get_slice(":", 1). get_slice(";", 0)
	var base64_data: String = splitted_args[1]
	loaded.emit(file_name, file_type, base64_data)

func _on_file_progress(args: Array) -> void:
	var current_bytes: int = args[0]
	var total_bytes: int = args[1]
	progress.emit(current_bytes, total_bytes)

func _on_file_error(args: Array) -> void:
	error.emit()

func _on_file_cancelled(args: Array) -> void:
	upload_cancelled.emit()

const js_source_code = """
function godotFileAccessWebStart() {
	let loadedCallback, progressCallback, errorCallback, loadStartCallback, cancelledCallback;

	function openFileDialog(accept) {
		const input = document.createElement("input");
		input.type = "file";
		if (accept) input.accept = accept;

		input.onchange = (event) => {
			if (!event.target.files || event.target.files.length === 0) {
				cancelledCallback && cancelledCallback();
				return;
			}

			const file = event.target.files[0];
			const reader = new FileReader();

			reader.onloadstart = () => {
				loadStartCallback && loadStartCallback(file.name);
			};

			reader.onload = () => {
				loadedCallback && loadedCallback(file.name, reader.result);
			};

			reader.onprogress = (e) => {
				if (e.lengthComputable) {
					progressCallback && progressCallback(e.loaded, e.total);
				}
			};

			reader.onerror = () => {
				errorCallback && errorCallback();
			};

			reader.onabort = () => {
				cancelledCallback && cancelledCallback();
			};

			reader.readAsDataURL(file); // or readAsArrayBuffer
		};

		input.click();
	}

	return {
		setLoadedCallback: cb => loadedCallback = cb,
		setProgressCallback: cb => progressCallback = cb,
		setErrorCallback: cb => errorCallback = cb,
		setLoadStartCallback: cb => loadStartCallback = cb,
		setCancelledCallback: cb => cancelledCallback = cb,
		setAcceptFiles: files => accept = files,
		open: () => openFileDialog(accept)
	};
}

var godotFileAccessWeb = godotFileAccessWebStart();
"""

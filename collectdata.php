<?php
if(isset($_POST["token"]) && !empty($_POST["token"])){
	if($_POST["token"] == "deck"){
		if(isset($_POST["data"])){
			file_put_contents("data.json", $_POST["data"]);
		}
	}
}

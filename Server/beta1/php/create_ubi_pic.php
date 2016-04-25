<?php
	$src = $_POST['src'];
	$dst = $_POST['dst'];
	$id = $_POST['id'];
	
	if (($img_info = getimagesize($src)) === FALSE)
		die("Image not found or not an image");
	
	if (!file_exists($dst)) {
		mkdir($dst, 0777, true);
	}
	
	$width = $img_info[0];
	$height = $img_info[1];
	$img1 = null;
	
	switch ($img_info[2]) {
		case IMAGETYPE_GIF  : $img1 = ImageCreateFromgif($src);  break;
		case IMAGETYPE_JPEG : $img1 = ImageCreateFromjpeg($src); break;
		case IMAGETYPE_PNG  : $img1 = ImageCreateFrompng($src);  break;
		default : die("Unknown filetype");
	}
	
	$x = imagesx($img1);
	$y = imagesy($img1);
	
	$img2 = imagecreatetruecolor($x, $y);
	$bg = imagecolorallocate($img2, 255, 255, 255);
	imagefill($img2, 0, 0, $bg);
	$e = imagecolorallocate($img2, 0, 0, 0);
	$r = $x <= $y ? $x : $y;
	imagefilledellipse ($img2, ($x/2), ($y/2), $r-15, $r-15, $e);
	imagecolortransparent($img2, $e);
	imagecopymerge($img1, $img2, 0, 0, 0, 0, $x, $y, 100);
	
	// CREATE BORDER WHITE
	$img3 = imagecreatetruecolor($x, $y);
	$bg = imagecolorallocate($img3, 0, 0, 0);
	imagefill($img3, 0, 0, $bg);
	$e = imagecolorallocate($img3, 0, 0, 0);
	$r = $x <= $y ? $x : $y;
	imagefilledellipse ($img3, ($x/2), ($y/2), $r-6, $r-6, $e);
	imagecolortransparent($img3, $e);
	imagecopymerge($img1, $img3, 0, 0, 0, 0, $x, $y, 100);
	
	$img4 = imagecreatetruecolor($x, $y);
	$bg = imagecolorallocate($img4, 255, 255, 255);
	imagefill($img4, 0, 0, $bg);
	$e = imagecolorallocate($img4, 100, 110, 110);
	$r = $x <= $y ? $x : $y;
	imagefilledellipse ($img4, ($x/2), ($y/2), $r, $r, $e);
	imagecolortransparent($img4, $e);
	imagecopymerge($img1, $img4, 0, 0, 0, 0, $x, $y, 100);
	
	// CREATE BORDER BLUE
	$img3 = imagecreatetruecolor($x, $y);
	$bg = imagecolorallocate($img3, 0, 0, 255);
	imagefill($img3, 0, 0, $bg);
	$e = imagecolorallocate($img3, 0, 0, 0);
	$r = $x <= $y ? $x : $y;
	imagefilledellipse ($img3, ($x/2), ($y/2), $r-10, $r-10, $e);
	imagecolortransparent($img3,$e);
	imagecopymerge($img1, $img3, 0, 0, 0, 0, $x, $y, 100);
	
	$img4 = imagecreatetruecolor($x, $y);
	$bg = imagecolorallocate($img4, 255, 255, 255);
	imagefill($img4, 0, 0, $bg);
	$e = imagecolorallocate($img4, 0, 0, 0);
	$r = $x <= $y ? $x : $y;
	imagefilledellipse ($img4, ($x/2), ($y/2), $r-3, $r-3, $e);
	imagecolortransparent($img4,$e);
	imagecopymerge($img1, $img4, 0, 0, 0, 0, $x, $y, 100);
	
	imagealphablending($img1, false);
	$transparency = imagecolorallocatealpha($img1, 0, 0, 0, 127);
	imagefill($img1, 0, 0, $transparency);
	imagesavealpha($img1, true);
	
	header("Content-type: image/png");
	imagepng($img1,$dst.$id."_1.png");
	
	// CREATE BORDER GREEN
	$img3 = imagecreatetruecolor($x, $y);
	$bg = imagecolorallocate($img3, 128, 255, 0);
	imagefill($img3, 0, 0, $bg);
	$e = imagecolorallocate($img3, 0, 0, 0);
	$r = $x <= $y ? $x : $y;
	imagefilledellipse ($img3, ($x/2), ($y/2), $r-10, $r-10, $e);
	imagecolortransparent($img3, $e);
	imagecopymerge($img1, $img3, 0, 0, 0, 0, $x, $y, 100);
	
	$img4 = imagecreatetruecolor($x, $y);
	$bg = imagecolorallocate($img4, 255, 255, 255);
	imagefill($img4, 0, 0, $bg);
	$e = imagecolorallocate($img4, 100, 110, 110);
	$r = $x <= $y ? $x : $y;
	imagefilledellipse ($img4, ($x/2), ($y/2), $r-3, $r-3, $e);
	imagecolortransparent($img4, $e);
	imagecopymerge($img1, $img4, 0, 0, 0, 0, $x, $y, 100);
	
	imagealphablending($img1, false);
	$transparency = imagecolorallocatealpha($img1, 0, 0, 0, 127);
	imagefill($img1, 0, 0, $transparency);
	imagesavealpha($img1, true);
	
	header("Content-type: image/png");
	imagepng($img1,$dst.$id."_2.png");
	
	imagealphablending($img1, false);
	$transparency = imagecolorallocatealpha($img1, 0, 0, 0, 127);
	imagefill($img1, 0, 0, $transparency);
	imagesavealpha($img1, true);
	
	header("Content-type: image/png");
	imagepng($img1,$dst.$id."_0.png");
	
	imagedestroy($img4);
	imagedestroy($img3);
	imagedestroy($img2);
	imagedestroy($img1);
?>

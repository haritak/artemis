<?php
require_once('PHPExcel.php');
require_once('PHPExcel/IOFactory.php');

const HOURS_PER_DAY = 7; 
const DAYS_PER_WEEK = 5;
const START_HOUR_GAP = 1;//gap when day hours start
const TEACHER_NAMES_COLUMN=0;

$teachers_included=array();

// load all teachers_included
$handle = new SQLite3("whosin.db");
$sql = "SELECT * FROM teachers WHERE using_groups=1";
$ret=$handle->query($sql);
while($row = $ret->fetchArray(SQLITE3_ASSOC)) {
  $teachers_included[]= $row['timetables_name'];
}

// Read the file
$fileName = $argv[1];
$objPHPExcel = PHPExcel_IOFactory::load($fileName); //load uploaded tmp file 

$highestRow = $objPHPExcel->setActiveSheetIndex(0)->getHighestRow();
$highestColumn = $objPHPExcel->setActiveSheetIndex(0)->getHighestColumn();
$highestColumnIndex = PHPExcel_Cell::columnIndexFromString($highestColumn); // e.g 5
$objWorksheet = $objPHPExcel->getActiveSheet();

for ($row = 1; $row <= $highestRow; ++$row) {
  $cell=trim($objWorksheet->getCellByColumnAndRow(TEACHER_NAMES_COLUMN, $row)->getValue()) ;
  if ($cell>""){
    $name = $cell;
    $name = str_replace("/","_",$name);
    /* if this is a new name, insert it! */
    $sql = "SELECT * from teachers WHERE timetables_name LIKE '%" . $name . "%'";
    $ret = $handle->query($sql);
    if ($ret->fetchArray(SQLITE3_ASSOC) == FALSE) {
      /* this is a new name, go on and insert it to whosin.db */
      $sql = "INSERT INTO teachers VALUES(NULL, '".$name."',0,1)";
      $op = $handle->prepare($sql);
      $op->execute();
    }
  }
}

$handle->close();
?> 




<?php

$hostList=array();
$roleList=array();
$file = fopen('saltServersList.csv','r'); 
while ($data = fgetcsv($file))
{
	if (strpos($data[0], "#") !== 0 )
	{
		$hosts[] = $data;
	}
}

foreach ($hosts as $arr)
{
	if ($arr[0]!="")
	{
		$roles = explode(";", $arr[2]);
		foreach ($roles as $role)
		{
			$r_part = explode("-", $role);
			$a="";
			foreach ($r_part as $r)
			{
				if ($a == "")
				{
					$a.=$r;
				}
				else
				{
					$a.="-".$r;
				}
				$hostList[$arr[0]]["roles"][$a]=$a;
				$hostList[$arr[0]]["location"][$arr[6]]=$arr[6];
				if ($arr[4] != "")
				{
					$roleList[$a][$arr[0]] = $arr[0]."\t".$arr[4];
				}
			}
		}
	}
}
fclose($file);

if (isset($_REQUEST["ip"]))
{
	echo urldecode(json_encode($hostList[$_REQUEST["ip"]]));
}
else if (isset($_REQUEST["role"]))
{
	if (isset($roleList))
	{
		echo implode("\n",$roleList[$_REQUEST["role"]]);
	}
}
else
{
	print_r($hostList);
	print_r($roleList);
}

?>
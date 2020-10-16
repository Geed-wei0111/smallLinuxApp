#!/bin/bash

#输入第一个日期
function initial()
{
	echo "please input a date(lenth=8)"
	read date1

	#判断是否为8位输入
	if [ ${#date1} -ne 8 ]
	then
		return 0
	fi
	#判断是否包含字母
	if [[ $date1 == *[a-zA-Z]* ]]
	then
		return 0
	fi
	#将字符串分割为年月日
	day=`expr $date1 % 100`
	date1=`expr $date1 / 100`
	month=`expr $date1 % 100`
	date1=`expr $date1 / 100`
	year=$date1
	#判断日期的格式是否正确
	isCorrected $year $month $day
	if [ $? -eq 0 ]
	then
		return 0
	fi
	return 1
}

#输入第二个日期
function initial2()
{
	#基本与上一个函数一致
	echo "please input another date(lenth=8)"
	read date2
	if [ ${#date2} -ne 8 ]
	then
		return 0
	fi
	if [[ $date2 == *[a-zA-Z]* ]]
	then
		return 0
	fi

	day2=`expr $date2 % 100`
	date2=`expr $date2 / 100`
	month2=`expr $date2 % 100`
	date2=`expr $date2 / 100`
	year2=$date2

	isCorrected $year2 $month2 $day2
	if [ $? -eq 0 ]
	then
		return 0
	fi
	return 1
}

#判断日期是否合格
function isCorrected(){
	echo "YEAR:"$1" MONTH:"$2" DAY:"$3
	
	#判断年份是否小于0，月份是否小于0或大于12
	if [ $1 -le 0 ] || [ $2 -le 0 ] || [ $2 -gt 12 ]
	then
		return 0
	fi
	
	#判断日是否小于合法值
	months=(31 0 31 30 31 30 31 31 30 31 30 31)
	isLeapYear $1
	if [ $? -eq 1 ]
	then
		months[1]=29
	else
		months[1]=28
	fi
	i=`expr $2 - 1`
	if [ ${months[$i]} -lt $3 ] && [ $3 -gt 0 ]
	then
		return 0
	fi
	
	return 1
}

#判断是否为闰年
function isLeapYear(){
    if [ `expr $1 % 4` -eq 0 ] && [ `expr $1 % 100` -ne 0 ] || [ `expr $1 % 400` -eq 0 ]
	then
		return 1
	else 
		return 0
	fi	
}

#判断该日期为星期几
function dayLocation()
{
	if [ $month -eq 1 ] || [ $month -eq 2 ]
	then
		month=`expr $month + 12`
		year=`expr $year - 1`
	fi
	part1=`expr $month + 1`
	part1=`expr $part1 \* 3 / 5`

	part2=`expr $day + 2 \* $month`

	part3=`expr $year + $year / 4 - $year / 100 + $year / 400 + 1`

	final=`expr $part1 + $part2 + $part3`
	final=`expr $final % 7`

	if [ $month -eq 13 ] || [ $month -eq 14 ]
	then
		month=`expr $month - 12`
		year=`expr $year + 1`
	fi

	echo "Weekend"$final
}

#时间间隔之不同年情况
function differentYear()
{
	sum=0;
	sum1=0;
	sum2=0;

	#先计算出第一年和最后一年之间有多少天
	y1=`expr $year + 1`
	y2=`expr $year2 - 1`
	if [ $y1 -lt $y2 ]
	then
		i=$y1
		while [ $i -le $y2 ]
		do
			isLeapYear $i
			if [ $? -eq 1 ]
			then
				sum=`expr $sum + 366`
			else
				sum=`expr $sum + 365`
			fi
			i=`expr $i + 1`
		done
	fi

	#计算最后一年距离第一天有多少天
	if [ $year -lt $year2 ]
	then
		months=(31 0 31 30 31 30 31 31 30 31 30 31)
		isLeapYear $year2
		if [ $? -eq 1 ]
		then
			months[1]=29
		else
			months[1]=28
		fi
		i=0
		j=`expr $month2 - 1`

		while [ $i -lt $j ]
		do
			sum1=`expr $sum1 + ${months[$i]}`
			i=`expr $i + 1`
		done
		sum1=`expr $sum1 + $day2 - 1`
	fi

	#计算第一年距离最后一天有多少天
	if [ $year -lt $year2 ]
	then
		months=(31 0 31 30 31 30 31 31 30 31 30 31)
		isLeapYear $year
		if [ $? -eq 1 ]
		then
			months[1]=29
		else
			months[1]=28
		fi
		i=$month
		j=12
		while [ $i -lt $j ]
		do
			sum2=`expr $sum2 + ${months[$i]}`
			i=`expr $i + 1`
		done
		k=`expr $month - 1`
		sum2=`expr $sum2 + ${months[$k]} - $day`
	fi

	sum=`expr $sum + $sum1 + $sum2`
	echo "Total:"$sum" days"
}

#时间间隔之同年情况
function sameYear()
{
	sum=0
	months=(31 0 31 30 31 30 31 31 30 31 30 31)
	isLeapYear $year
	if [ $? -eq 1 ]
	then
		months[1]=29
	else
		months[1]=28
	fi
	
	#计算相隔月份有多少天
	i=$month
	j=`expr $month2 - 1`
	while [ $i -lt $j ]
	do
		sum=`expr $sum + ${months[$i]}`
		i=`expr $i + 1`
	done
	#加上最后一月距离第一天有多少，第一月距离最后一天有多少
	k=`expr $month - 1`
	sum=`expr $sum + ${months[$k]} - $day`
	sum=`expr $sum + $day2 - 1`
	echo "Total:"$sum" days"
}

#时间间隔之同年同月情况
function sameMonth()
{
	#直接相减即可得到
	result=`expr $day2 - $day`
	echo "total:"$result" days"
}

#问题1
function Qone(){
	initial
	if [ $? -eq 1 ]
	then
		isLeapYear $year
		if [ $? -eq 1 ]
		then
			echo "IsLeap"
		else
			echo "NotLeap"
		fi
	else
		echo "Wrong Date"
	fi
}

#问题2
function Qtwo()
{
	initial
	if [ $? -eq 1 ]
	then	
		dayLocation
	else
		echo "Wrong Date"
	fi
}

#问题3
function Qthree()
{
	initial
	if [ $? -eq 0 ]
	then
		echo "Wrong date"
		return 0
	fi
	initial2
	if [ $? -eq 0 ]
	then
		echo "Wrong date"
		return 0
	fi
	
	
	if [ $year -eq $year2 ]
	then
		if [ $month -eq $month2 ]
		then
			sameMonth
		else
			sameYear
		fi
	else
		differentYear
	fi
}

#接受无用输入
trash=0

#接受日期
date1=0
date2=0

#保存处理后的年月日
year=0
month=0
day=0
year2=0
month2=0
day2=0

#菜单选项
choice=1


#菜单兼“主函数”
while [ $choice != 0 ]
do
	echo "please input a number to use function"
	echo "[0]exit..."
	echo "[1]leap year"
	echo "[2]day location"
	echo "[3]days between two dates"
	echo "Your choice is :"
	read choice
	if [ ${#choice} -eq 0 ]
	then
		echo "please input a number..."
		choice=4
	fi
	
	if [ $choice -eq 1 ]
	then
		Qone
	elif [ $choice -eq 2 ]
	then
		Qtwo
	elif [ $choice -eq 3 ]
	then 
		Qthree
		trash=$?	
	elif [ $choice -eq 0 ]
	then
		echo "Bye!"
	else
		echo "Nothing here"
	fi
	echo "......Press enter to continue......"
	echo "	"
	echo "	"
	read enter
done

#!/bin/bash

# test messages and coloring
power1=90000
p=7777
echo -e "\e[30m\e[42mRunning cburn SAT to stress test system\e[0m"
echo -e "\e[5mWaiting 30s for SAT to fully run\e[0m\n"

echo -e "\e[4mClear existing policy 1\e[0m"   
echo -e "\e[4mAverage Power=\e[44m$power1\e[0m"
echo -e 
echo -e "\e[4mApply power policy #1(70% of current power)\e[0m"
echo -e "\e[4mSetting power limit to $(($power1*7/10))w\e[0m"
echo -e "\e[4mSampling power with policy enable:\e[44m$p\e[0m"
echo -e "\e[4mAverage power with policy enable:\e[44m$p\e[0m"
echo -e "\e[4mAverage power without policy:\e[44m$power1\e[0m"
echo -e "\e[4mtolerance:tolerance\e[0m"
echo -e "\e[30m\e[42mPASS!\e[0m"
echo -e "\e[5m\e[41m\e[30mFAIL\e[0m\e[4m,please check logs\e[0m"
echo -e "\e[4mMake sure system is removed from SPM!\e[0m"
echo -e "Clear existing policy 1 and nm power policy test is finished\e[0m"
echo -e "SAT will be killed automatically, no worry.\e[0m"
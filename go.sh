#!/bin/bash
for i in {1..50}
do
  ./runme <testy2/test"$i".in >testy2/test"$i".out
done

cmake_minimum_required(VERSION 3.18.1)
project(laqta_security)

add_library(security SHARED security_checks.cpp)
find_library(log-lib log)
target_link_libraries(security ${log-lib})

## This file is part of SimInf, a framework for stochastic
## disease spread simulations.
##
## Copyright (C) 2015 Pavol Bauer
## Copyright (C) 2017 -- 2019 Robin Eriksson
## Copyright (C) 2015 -- 2019 Stefan Engblom
## Copyright (C) 2015 -- 2019 Stefan Widgren
##
## SimInf is free software: you can redistribute it and/or modify
## it under the terms of the GNU General Public License as published by
## the Free Software Foundation, either version 3 of the License, or
## (at your option) any later version.
##
## SimInf is distributed in the hope that it will be useful,
## but WITHOUT ANY WARRANTY; without even the implied warranty of
## MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
## GNU General Public License for more details.
##
## You should have received a copy of the GNU General Public License
## along with this program.  If not, see <https://www.gnu.org/licenses/>.

library(SimInf)
library(tools)
source("util/check.R")

## For debugging
sessionInfo()

## Check missing and invalid model argument
res <- assertError(package_skeleton())
check_error(res, "Missing 'model' argument.")

res <- assertError(package_skeleton(5))
check_error(res, "'model' argument is not a 'SimInf_model'.")

## Check missing 'ldata', 'gdata' and 'v0' parameters
m <- mparse(transitions = "@ -> 1 -> S",
            compartments = "S",
            u0 = data.frame(S = 0),
            tspan = 1:10)
stopifnot(is.null(SimInf:::create_model_R_object_ldata(m)))
stopifnot(is.null(SimInf:::create_model_R_object_gdata(m)))
stopifnot(is.null(SimInf:::create_model_R_object_v0(m)))

## Check package_skeleton
m <- mparse(transitions = c("@ -> a -> S",
                            "S -> b*S*I/(S+I+R) -> I",
                            "I -> g*I -> R"),
            compartments = c("S", "I", "R"),
            ldata = data.frame(a = 1),
            gdata = c(b = 0.16),
            u0 = data.frame(S = 99, I = 1, R = 0),
            v0 = data.frame(g = 0.077),
            tspan = 1:10)

path <- tempdir()
package_skeleton(m, name = "SIR", path = path)

stopifnot(file.exists(file.path(path, "SIR", "DESCRIPTION")))
stopifnot(file.exists(file.path(path, "SIR", "NAMESPACE")))
stopifnot(file.exists(file.path(path, "SIR", "man", "SIR-class.Rd")))
stopifnot(file.exists(file.path(path, "SIR", "man", "SIR.Rd")))
stopifnot(file.exists(file.path(path, "SIR", "man", "run-methods.Rd")))
stopifnot(file.exists(file.path(path, "SIR", "R", "model.R")))
stopifnot(file.exists(file.path(path, "SIR", "src", "model.c")))

## Check that it fails if path exists
res <- assertError(package_skeleton(m, name = "SIR", path = path))
check_error(res, "already exists.", FALSE)

## Cleanup
unlink(path, recursive = TRUE)

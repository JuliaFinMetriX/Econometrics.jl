# Econometrics

[![Build Status](https://travis-ci.org/cgroll/Econometrics.jl.png)](https://travis-ci.org/cgroll/Econometrics.jl)

The Econometrics.jl package contains functionalities for (financial)
econometric research. It comprises:

- general utilities to handle prices / returns
- new distributions (t-location-scale)
- univariate and multivariate models

# Models

Econometric models are represented by the following super types:

- `AbstrModel`
- `AbstrUnivarModel <: AbstrModel`
- `AbstrMultivarModel <: AbstrModel`

For each fully specified model, the following functions should be
implemented:

- `display`
- `description`: more detailed information on a fully specified model 
- `simulate`
- `resimulate`

In addition, if coefficients have not been specified yet, the model
type can be used to estimate / fit the model to data:

- `estimate`: estimate the model and return the fully specified model
- `fit`: estimate the model and return a fully specified model
  together with additional information on:
	- `data`: data used
	- `nllh`: negative log-likelihood value
	- additional information: for example, estimated sigma series for
     GARCH models

More precisely, the following concrete models are implemented:

- `NormIID <: AbstrUnivarModel`
	- constant univariate normal distribution
- `TlsIID <: AbstrUnivarModel`
	- constant t-location-scale distribution
- `GARCH_1_1{Normal} <: AbstrUnivarModel`
	- GARCH(1,1) with normally distributed returns
- `GARCH_1_1{t} <: AbstrUnivarModel`
	- GARCH(1,1) with t-distributed returns


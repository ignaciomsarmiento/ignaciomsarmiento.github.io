---
layout: blog
title: RK's Ford vs Ferrari Revisited
tags: R-Bloggers R Quantile Computation

---


A couple of weeks back [Roger Koenker](http://www.econ.uiuc.edu/~roger/) reminded me about my post comparing [*quantreg* vs. *Rmosek*](https://ignaciomsarmiento.github.io/2017/01/20/Quantile-and-OLS-Regression-with-Rmosek.html). In Angrist's application, *Rmosek* was faster than the traditional Barrondale and Roberts. However, [Roger](http://www.econ.uiuc.edu/~roger/) was curious about how it would compare to the interior point algorithms implemented using FORTRAN in [*quantreg*](https://cran.r-project.org/web/packages/quantreg/quantreg.pdf). Here are his results (reproduced from [RK's blog](http://davoidofmeaning.blogspot.com/) with his permission) run on his mac mini:


``` r
Unit: milliseconds
                               expr       min        lq      mean    median
 qr.mosek.dual.rep(X, y, tau = tau)  346.9841  357.2982  365.9998  364.2814
        rq.fit.fnb(X, y, tau = tau)  193.7651  194.5455  202.1676  195.2470
       rq.fit.sfn(Xs, y, tau = tau)  330.3882  341.1280  365.0841  349.7058
         rq.fit.br(X, y, tau = tau) 7266.7237 7270.0682 7289.8437 7274.8538
        uq       max neval
  370.6428  462.1361   100
  206.7692  288.0764   100
  369.8432  451.3124   100
 7285.0870 7522.6136   100
```

Where `qr.mosek.dual.rep` is my *Rmosek* implementation. `rq.fit.fnb` implements the basic Frisch-Newton interior point algorithm and `rq.fit.sfn` it's sparse version. `rq.fit.br` uses the simplex approach of Barrondale and Roberts. 


A couple of things to note `rq.fit.br` (Barrondale and Roberts) is much slower, absolutely and relatively, on his implementation. Interior points perform quite well, better than *Rmosek*. Sparsity doesn't help (Angrist problem is not very sparse).


Finally, and probably the most important thing of this post, go an read Roger's blog and work. RK's blog: [''Da Void of Meaning''](http://davoidofmeaning.blogspot.com/) is fantastic. He doesn't post very often but it is absolutely worthwhile. 


**Comments and suggestions are always welcomed. You can send them to `srmntbr2` at `illinois.edu`.**


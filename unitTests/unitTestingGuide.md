q ~/HSBC/unitTests/k4unit.q


KUltf `:tests.csv

q)KUT
action  ms bytes  lang code          repeat minver file        comment
------------------------------------------------------------------------------------------
comment 0  0      q                  1      0      :tests.csv “this will just be ignored”
before  0  0      k    aa::22        1      0      :tests.csv “”
before  0  0      k    aa::22        1      0      :tests.csv “”
before  0  0      q    aa::22        1      0      :tests.csv “”
before  0  0      q    aa::22        1      0      :tests.csv “comment ”

Run the tests: KUrt[]

Inspect results: KUTR

q)show select from KUTR where not ok
q)show select from KUTR where not okms
q)show select count i by ok,okms,action from KUTR
q)show select count i by ok,okms,action,file from KUTR

KUstr[] saves the table KUtr to a file KUTR.csv
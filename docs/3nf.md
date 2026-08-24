# Third Normal Form and Dependency Preservation



## Scope



The following analysis covers the relations affected by the Sprint 5 design changes:



1. Equipment(name, tool\_id, cost)
2. Tutorial(resource\_id, steps\_count, estimated\_completion\_minutes)
3. Hobbies(hobby\_id, name, description, difficulty, review\_count, avg\_rating)
4. Review(user\_id, hobby\_id, review\_date, rating, comment)



CHECK constraints were added to Equipment and Tutorial, review\_count and avg\_rating were added to Hobbies. A trigger on Review maintains the two derived attributes whenever a review is inserted. 



NULL demos use relations such as Video and Resources, but those did not change their schemas or functional dependencies. 



## FD's



#### Equipment



tool\_id = primary key:

tool\_id -> name

tool\_id -> cost



#### Tutorial



resource\_id = primary key

resource\_id -> steps\_count

resource\_id -> estimated\_completion\_minutes



#### Hobbies



hobby\_id = primary key

hobby\_id -> name

hobby\_id -> description

hobby\_id -> difficulty

hobby\_id -> review\_count

hobby\_id -> avg\_rating



#### Review



user\_id, hobby\_id, review\_date = primary key

(user\_id, hobby\_id, review\_date) -> rating

(user\_id, hobby\_id, review\_date) -> comment



## Minimal Basis

1. #### Every FD has a singleton right-hand side



Every FD already has exactly one attribute on right-hand side.



#### 2\. If any FD is removed, we no longer have a basis



Each FD is necessary because if any are removed its right-hand side attributes cannot be derived from  remaining dependencies.



Ex) If hobby\_id -> avg\_rating is removed, there is no remaining dependency that can derive avg\_rating from hobby\_id.



#### 3\. If we remove any attribute from the left-hand side of any FD, we no longer have a basis



The determinants tool\_id, hobby\_id, and resource\_id each have only one attribute, so none can be reduced further. 



Review:



(user\_id, hobby\_id, review\_date) -> rating

removing any attribute causes the dependency to fail:

(user\_id, hobby\_id)+, does not determine `rating`, because a user may review the same hobby on different dates.

(user\_id, review\_date)+, does not determine `rating`, because the hobby is not identified.

(hobby\_id, review\_date)+, does not determine `rating`, because the user is not identified.

The same reasoning applies to (user\_id, hobby\_id, review\_date) -> comment.



Therefore all sets are minimal



## 3NF Synthesis



#### Equipment:



Original: Equipment(tool\_id, name, cost)

Minimal Basis: tool\_id -> name, tool\_id -> cost

E1(tool\_id, name)

E2(tool\_id, cost)

The candidate key of original is {tool\_id}, both E1 and E2 contain tool\_id, which is a superkey of original. 

Final synthesized relations: E1(tool\_id, name) and E2(tool\_id, cost)



#### Tutorial:



Original: Tutorial(resource\_id, steps\_count, estimated\_completion\_minutes)

Minimal Basis: resource\_id -> steps\_count, resource\_id -> estimated\_completion\_minutes

T1(resource\_id, steps\_count)

T2(resource\_id, estimated\_completion\_minutes)

The candidate key of original is {resource\_id}, both T1 and T2 contain resource\_id, so at least one contains a superkey of original.

Final sysnthesized relations: T1(resource\_id, steps\_count) and T2(resource\_id, estimated\_completion\_minutes)



#### Hobbies:



Original: Hobbies(hobby\_id, name, description, difficulty, review\_count, avg\_rating)

Minimal Basis: hobby\_id -> name, hobby\_id -> description, hobby\_id -> difficulty, hobby\_id -> review\_count, hobby\_id -> avg\_rating

H1(hobby\_id, name)

H2(hobby\_id, description) 

H3(hobby\_id, difficulty) 

H4(hobby\_id, review\_count) 

H5(hobby\_id, avg\_rating)

The candidate key of original is {hobby\_id}, every sub-relation contains hobby\_id, so synthesis contains superkey or original.

Final synthesized relations: H1(hobby\_id, name), H2(hobby\_id, description), H3(hobby\_id, difficulty), H4(hobby\_id, review\_count), H5(hobby\_id, avg\_rating)



#### Review:



Original: Review(user\_id, hobby\_id, review\_date, rating, comment)

Minimal Basis: (user\_id, hobby\_id, review\_date) -> rating, (user\_id, hobby\_id, review\_date) -> comment

R1(user\_id, hobby\_id, review\_date, rating) 

R2(user\_id, hobby\_id, review\_date, comment)

The candidate key of original is {user\_id, hobby\_id, review\_date}, which is in both R1 and R2, so synthesized relation already contains superkey of original.

Final synthesized relations: R1(user\_id, hobby\_id, review\_date, rating), R2(user\_id, hobby\_id, review\_date, comment)



## Comparison with Existing BCNF Design



### Existing BCNF Relations:



Equipment(tool\_id, name, cost), tool\_id is primary key, so Equipment is in BCNF.



Tutorial(resource\_id, steps\_count, estimated\_completion\_minutes), resource\_id is primary key, so Tutorial in BCNF.



Hobbies(hobby\_id, name, description, difficulty, review\_count, avg\_rating), hobby\_id is primary key, so Hobbies in BCNF.



Review(user\_id, hobby\_id, review\_date, rating, comment), (user\_id, hobby\_id, review\_date) is primary key, so Review in BCNF.



### Comparison:



The synthesis algorithm produced:

E1(tool\_id, name), E2(tool\_id, cost)



T1(resource\_id, steps\_count), T2(resource\_id, estimated\_completion\_minutes)



H1(hobby\_id, name), H2(hobby\_id, description), H3(hobby\_id, difficulty), H4(hobby\_id, review\_count), H5(hobby\_id, avg\_rating)



R1(user\_id, hobby\_id, review\_date, rating), R2(user\_id, hobby\_id, review\_date, comment)



The existing BCNF schema keeps attributes having the same determinant together, while the 3NF synthesis creates a separate porojection for each FD.

Ex) Equipment(tool\_id, name, cost) stores both dependencies together, whereas the 3NF synthesis gives E1(tool\_id, name) and E2(tool\_id, cost). Both designs satisfy at least 3NF, but the existing design avoids unnecessary fragmentation. 



### Dependency Preservation



Every FD remains completely inside one existing relation for the existing BCNF design.

Ex) tool\_id -> cost is contained in Equipment and hobby\_id -> avg\_rating is contained in Hobbies. 



The synthesized design also preserves every dependency since each FD directly generated one of the synthesized relations. 

Ex) tool\_id -> cost is represented by E2(tool\_id, cost). The same holds for every dependency in the minimal basis. 



### Overall Comparison



Existing Design: BCNF, Fragmentation = low, is Dependency Preserving

3NF Synthesis: 3NF, Fragmentation = higher, is Dependency Preserving







## Constructed Example Where BCNF Loses Dependency Preservation



Our Sprint 5 relations are already in BCNF and preserve their functional dependencies. To show why BCNF is not always preferable to 3NF, consider the following constructed relation: R(A, B, C), with FD's A, B -> C and C -> B.



Taking the closure of {A, B}:



{A, B}+ = {A, B, C} because A, B -> C. Therefore {A, B} is a candidate key.



Taking the closure of {A, C}:



{A, C}+ = {A, C, B} because C -> B. Therefore {A, C} is also a candidate key.



The candidate keys are therefore:{A, B} and {A, C}



Since A, B, and C each appear in at least one candidate key, all three are prime attributes.



This satisfies 3NF but violates BCNF. For example consider FD, C-> B. The closure of {C} is {C, B}, so C does not determine A and is therefore not a superkey. This violates BCNF, because BCNF requires the left-hand side of every non-trivial FD to be a superkey. However, the relation still satisfies 3NF. For 3NF, a non-trivial FD is allowed when either its left-hand side is a superkey or its right-hand-side attribute is prime. Here, B is prime because it appears in the candidate key {A, B}. This also demonstrates the diagnostic case from our sprint goal: C is itself a prime attribute because it appears in the candidate key {A, C}, but C alone is not a key.



### BCNF Decomposition:



R1(C, B)

&#x20;   key: {C}

&#x20;   FD:  C -> B



R2(A, C)

&#x20;   key: {A, C}



This decomposition is lossless, but it does not preserve every original functional dependency.



The dependency C -> B is preserved directly in R1. However, the original dependency A, B -> C is no longer contained in either relation. R1 contains B and C but not A, while R2 contains A and C but not B. Therefore A, B -> C cannot be enforced by checking either decomposed relation independently. The relations would have to be joined in order to check the original dependency.



### 3NF Comparision:



If we instead keep the original relation R(A, B, C) it remains in 3NF because the only BCNF-violating dependency, C → B, has the prime attribute B on its right-hand side. Both original dependencies remain directly enforceable A, B -> C and C -> B.



This shows the trade-off between 3NF and BCNF, since BCNF has the stronger normalization condition, but decomposition to BCNF loses dependency preservation. 3NF allows for non-superkey determinants when the dependent attribute is prime which can preserve constraints that would otherwise require a join to enforce. 



## Conclusion



For the actual Sprint 5 schema, the existing BCNF design provides both strong normalization and dependency preservation. Since in our existing Sprint 5 schema the existing BCNF relations already preserve every FD, there is no trade-off that arises and the 3NF synthesis introduces relations without providing any advantage, we will retain the existing BCNF design rather than replace it with more fragmented relations.
















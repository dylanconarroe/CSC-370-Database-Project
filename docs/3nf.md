# Third Normal Form and Dependency Preservation



### Scope



The following analysis covers the relations affected by the Sprint 5 design changes:



1. Equipment(name, tool\_id, cost)
2. Tutorial(resource\_id, steps\_count, estimated\_completion\_minutes)
3. Hobbies(hobby\_id, name, description, difficulty, review\_count, avg\_rating)
4. Review(user\_id, hobby\_id, review\_date, rating, comment)



CHECK constraints were added to Equipment and Tutorial, review\_count and avg\_rating were added to Hobbies. A trigger on Review maintains the two derived attributes whenever a review is inserted. 



NULL demos use relations such as Video and Resources, but those did not change their schemas or functional dependencies. 



### FD's



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



### Minimal Basis



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






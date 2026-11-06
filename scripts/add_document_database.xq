xquery version '4.0' ;

import module namespace functx = 'http://www.functx.com';
import module namespace G = "globals";
import module namespace script = "script";
import module namespace add_doc = "backend/update/add_document";

declare namespace dots = "https://github.com/dots-suite/dots";
declare namespace tei = "http://www.tei-c.org/ns/1.0";

declare variable $dbName external;
declare variable $docPath external;
declare variable $parentId external := "";


if (doc($docPath)/tei:TEI)
then
  let $isTop  := $parentId = ""
  let $parent := 
    if ($isTop) 
    then () 
    else db:get($dbName)//*:collection[@dtsResourceId = $parentId]
  return
    if ($isTop or $parent)
    then
      let $parentPath :=
        if ($isTop) then ""
        else 
          if (contains($parent, "/")) 
          then functx:substring-before-last($parent, "/")
          else string($parent)
      let $docName := functx:substring-after-last($docPath, "/")
      let $target  := string-join(($parentPath[. != ""], $docName), "/")
      return
        if (db:exists($dbName, $target))
        then script:error(concat("Le document ", $docName, " est déjà présent dans la base."))
        else
          (
            add_doc:handleAddition($dbName, $docPath, $parentPath),
            script:success(concat("Le document a bien été ajouté à la base '", $dbName, "'."))
          )
    else script:error(concat("La collection ", $parentId, " n'existe pas.")) 
  else
    script:error(concat("Le fichier '", $docPath, "' n'existe pas."))
  
  
  

/* lexical grammar */
%lex

%%

"["         return 'OPEN_LINK';
"]"         return 'CLOSE_LINK';
[^\[\]]+    return 'TEXT';
<<EOF>>     return 'EOF';

/lex


%start entire_node
%% /* language grammar */

entire_node
    : items EOF
        {return $1;}
    | EOF
        {return [];}
    ;

link
    : OPEN_LINK TEXT CLOSE_LINK
        {$$ = {type: 'link', value: $2} }
    ;

text
    : TEXT
        {$$ = {type: 'text', value: $1} }
    ;

item
    : link
        {$$ = $1}
    | text
        {$$ = $1}
    ;

items
    : item
        {$$ = [$1]}
    | item items
        {$$ = [$1].concat($2)}
    ;

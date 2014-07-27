%{
	
	#include<stdio.h>
	#include<string.h>
	#include <stdlib.h>
	#include <stdarg.h>

	#define IDENTIFIER 257
	#define KEYWORD 258
	#define INTEGER_CONST 259
	#define CHARACTER_CONST 260
	#define STRING_CONST 261
	#define FLOAT_CONST 262

	typedef union { 
	     struct {
		 int value;
		 int line_number;
	     } integer_value;
	     struct {
		 char *value;
		 int line_number;
	     } string_value;
	     int line_number;
	} YYSTYPE;

	struct lineno
	{
		int no;		
		struct lineno *next;
	}; 
	struct token
	{
		struct lineno *head;
		struct lineno *tail;
		char *name;
		char type;
		int value;
	};

	struct table
	{
		struct token *tk;
		struct table *next;
	};

	struct table *sfront=NULL,*cfront=NULL,*opfront=NULL;

	YYSTYPE yylval;
	int Number_Of_Errors = 0;
	char identifier[200];
	int Current_Line = 1,l=0;
	char *tokenNames[] = { "IDENTIFIER","KEYWORD","INTEGER_CONST","CHARACTER_CONST","STRING_CONST","FLOAT_CONST"};
	char *tableName[] = { "Symbol Table","Constant Table","Operator Table"};

	char *tokenName(int token) 
	{
	  	if (token < 257 || token > 262)
	    		return "BAD TOKEN";
	  	else
	    		return tokenNames[token-257];
	}

	void newline() 
	{
	  	Current_Line++;
	}

	void Error(int position, char *message,char *symbol_name)
	{
		va_list ap;
	 	Number_Of_Errors++;
	 	fprintf(stderr,"Error in line %d:", position);
	 	fprintf(stderr,"%s %s\n",message,symbol_name);
	}

	int numErrors() 
	{
	 	return Number_Of_Errors;
	}

	int anyErrors() 
	{
	 	return Number_Of_Errors;
	}

	struct table *insert(struct table *front,struct token *tk)
	{
		int i;
		struct table *table1,*temp;

		struct token *current_token;

		struct lineno *temp_lineno;	
		struct lineno *current_token_lineno;
	
		table1=(struct table *)malloc(sizeof(struct table));

		table1->tk=tk;

		table1->next=NULL;

		if(front==NULL)
		{
			front=table1;
		}
		else
		{
			temp=front;

		//	if(tk->type=='I')
			{
				while(temp->next!=NULL)
				{
					current_token=temp->tk;
					if(strcmp(current_token->name,tk->name)==0)
					{	

						current_token_lineno=(struct lineno *)malloc(sizeof(struct lineno));
						current_token_lineno->no=(tk->head)->no;
						current_token_lineno->next=NULL;
															
						temp_lineno=current_token->tail; 
						temp_lineno->next=current_token_lineno;
						current_token->tail=current_token_lineno;

						return front;
					}
					temp=temp->next;
				}
				current_token=temp->tk;
				if(strcmp(current_token->name,tk->name)==0)
				{	
	
					current_token_lineno=(struct lineno*)malloc(sizeof(struct lineno));
					current_token_lineno->no=(tk->head)->no;
					current_token_lineno->next=NULL;
				
					temp_lineno=current_token->tail;
					temp_lineno->next=current_token_lineno;
					current_token->tail=current_token_lineno;

					return front;
				}
				temp->next=table1;
			}
		/*	else
			{
				while(temp->next!=NULL)
				{
					temp=temp->next;
				}

				temp->next=table1;
			}
		*/		
		}
		return front;
	}

	void display(struct table *front,int flag)
	{
		int i,j;
		struct table *temp;

		struct token *tk;
		struct lineno *temp_lineno;
	
		FILE *fp;
		fp=fopen("output.sym","w");

		temp=front;

		if(temp==NULL)
		{

			printf("\n%s is empty\n",tableName[flag]);
		}
		else
		{
			printf("\n\n%s:\n\nName\t\t\t\tType\t\tLine No.\n\n",tableName[flag]);
			while(temp!=NULL)
			{
				tk=temp->tk;
				temp_lineno=tk->head;
				if(strlen(tk->name)<8)
				{
					printf("%s\t\t\t\t%c\t\t",tk->name,tk->type);
					fprintf(fp,"%s\t\t\t\t%c\t\t",tk->name,tk->type);
				}
				else if(strlen(tk->name)<16)
				{
					printf("%s\t\t\t%c\t\t",tk->name,tk->type);
					fprintf(fp,"%s\t\t\t%c\t\t",tk->name,tk->type);
				}
				else if(strlen(tk->name)<24)
				{	//printf("\n>16\n");
					printf("%s\t\t%c\t\t",tk->name,tk->type);
					fprintf(fp,"%s\t\t%c\t\t",tk->name,tk->type);
				}		
				else
				{	
					printf("%s\t%c\t\t",tk->name,tk->type);
					fprintf(fp,"%s\t%c\t\t",tk->name,tk->type);
				}		


				printf("%d",temp_lineno->no);
				fprintf(fp,"%d",temp_lineno->no);	
				temp_lineno=temp_lineno->next;

				while(temp_lineno!=NULL)
				{
					printf(",%d",temp_lineno->no);
					fprintf(fp,",%d",temp_lineno->no);	
					temp_lineno=temp_lineno->next;			
				}
				printf("\n");
				fprintf(fp,"\n");
				temp=temp->next;
			}
		}
		fclose(fp);
	
	}

%}

letter [a-zA-Z]
digit [0-9]

%x DOUBLEQUOTE
%x SINGLEQUOTE
%x ENDQUOTE
%x COMMENT
%x SINGLE_LINE_COMMENT
%x IDENT
%x ERROR
%x DIGIT
%x DECIMAL
%x HASH

%%

("auto"|"break"|"case"|"char"|"const"|"continue"|"default"|"do"|"double"|"else"|"enum"|"extern"|"float"|"for"|"goto"|"if"|"int"|"long"|"register"|"return"|"short"|"signed"|"sizeof"|"static"|"struct"|"switch"|"typedef"|"union"|"unsigned"|"void"|"volatile"|"while") {				
					yylval.string_value.line_number = Current_Line;
					yylval.string_value.value=(char *)malloc(sizeof(yytext)+1);
					strcpy(yylval.string_value.value,yytext);
					return KEYWORD;
				}

"#"				{
					BEGIN(HASH);
				}
<HASH>"\n"			{
					BEGIN(INITIAL);	
				}
<HASH>.				{ }

"\"" 				{
					l=0;
					BEGIN(DOUBLEQUOTE);
				}
<DOUBLEQUOTE>"\""		{
					identifier[l]='\0';
					yylval.string_value.line_number = Current_Line;
					yylval.string_value.value=(char *)malloc(l+1);
					strcpy(yylval.string_value.value,identifier);
					BEGIN(INITIAL);
					return STRING_CONST;
				}
<DOUBLEQUOTE>.			{ 
					
					identifier[l++]=yytext[0];
				} 

<DOUBLEQUOTE>"\n"		{ 
					newline();				
				}

"\'"				{
					l=0;
					BEGIN(SINGLEQUOTE);
				}

<SINGLEQUOTE>.			{
					identifier[l++]=yytext[0];
					BEGIN(ENDQUOTE);				
				}

<ENDQUOTE>"\'"			{	
					identifier[l]='\0';
					yylval.string_value.line_number = Current_Line;
					yylval.string_value.value=(char *)malloc(l+1);
					strcpy(yylval.string_value.value,identifier);
					BEGIN(INITIAL);
					return CHARACTER_CONST;
				}

<ENDQUOTE>.			{	
					identifier[l++]=yytext[0];
					BEGIN(ERROR);				
				}


"/*"				{	BEGIN(COMMENT);
				}

<COMMENT>"*/"			{	BEGIN(INITIAL);
				}

<COMMENT>.			{ }
<COMMENT>"\n"			{	newline(); 
				}

"//"				{	BEGIN(SINGLE_LINE_COMMENT);
				}
<SINGLE_LINE_COMMENT>.		{ }

<SINGLE_LINE_COMMENT>"\n"	{
					BEGIN(INITIAL);
				}	

" "            			{ }
\n             			{ 	
					newline();
				}




({letter}|_)			{
					BEGIN(IDENT);	
					l=0;
					identifier[l++]=yytext[0];				
				}

<IDENT>({letter}|{digit}|_)	{ 
					identifier[l++]=yytext[0];

				}


<IDENT>[^,);=(<>!.\-\[\]\{\}'\n'\ ]	{
					identifier[l++]=yytext[0];
					BEGIN(ERROR);
				}

<IDENT>.			{
					identifier[l]='\0';
					yylval.string_value.line_number = Current_Line;
					yylval.string_value.value=(char *)malloc(l);
					strcpy(yylval.string_value.value,identifier);
					BEGIN(INITIAL);
					if(l>32)
						Error(Current_Line,"Maximum length of the identifier exceeded 32 characters",identifier);
					return IDENTIFIER;	
				}

<ERROR>[,);=(<>!.\-\[\]\{\}'\n'\ ] 	{
					identifier[l]='\0';
					Error(Current_Line,"Invalid identifier",identifier);
					BEGIN(INITIAL);
				}
<ERROR>.			{
					identifier[l++]=yytext[0];
				}


<DIGIT>{digit}			{
					
					identifier[l++]=yytext[0];
				}

<DIGIT>[!\%^&*-+=|;<>?/ \n\t\)\]\}]	{
					
					identifier[l]='\0';
					yylval.integer_value.line_number = Current_Line;
					yylval.integer_value.value=atoi(identifier);
					BEGIN(INITIAL);
					return INTEGER_CONST;
	
				}

<DIGIT>"\."			{
					BEGIN(DECIMAL);
					identifier[l++]=yytext[0];								
				}

<DECIMAL>"\."			{	
					identifier[l++]=yytext[0];
					BEGIN(ERROR);
				}

<DECIMAL>[!\%^&*-+=|;<>?/ \n\t\)\]\}] {
						identifier[l]='\0';
					yylval.string_value.line_number = Current_Line;
					yylval.string_value.value=identifier;
					BEGIN(INITIAL);
					return FLOAT_CONST;
						
					}

<DECIMAL>{digit}		{
					identifier[l++]=yytext[0];
				}

<DECIMAL>.			{	
					
					identifier[l++]=yytext[0];
					BEGIN(ERROR);			
				}


<DIGIT>.			{
					
					identifier[l++]=yytext[0];
					BEGIN(ERROR);				
				}


{digit}				{
					
					BEGIN(DIGIT);				
					l=0;
					identifier[l++]=yytext[0];				
				}

. ;

%%


int main(int argc,char *argv[])
{
	int tok;

	struct token *tk;
	struct lineno *sym_lineno;

	if (argc!=2) 
	{
   		fprintf(stderr,"usage: %s filename\n",argv[0]); 
   		exit(1);
 	}
	yyin=fopen(argv[1],"r");
	if (yyin == NULL) 
	{
   		fprintf(stderr,"Cannot open file:%s\n",argv[1]);
 	} 
	else 
	{
		for(;;) 
		{
			

     			tok=yylex();
     			
			if (tok==0) 
			{
				break;
			}
		
			//printf("%d\n",tok);

		     	switch(tok) 
			{
				case KEYWORD:		//printf("line:%2d %15s  value = %s\n",
		      					//yylval.string_value.line_number, tokenName(tok),
		      					//yylval.string_value.value);

							tk=(struct token *)malloc(sizeof(struct token));
							sym_lineno=(struct lineno *)malloc(sizeof(struct lineno));
							sym_lineno->no=yylval.string_value.line_number;
							sym_lineno->next=NULL;

							tk->head=sym_lineno;
							tk->tail=sym_lineno;
							
							//tk->lineno[0]=yylval.string_value.line_number;
							tk->name=(char *)malloc(sizeof(yylval.string_value.value)+1);
							strcpy(tk->name,yylval.string_value.value);
							tk->type='K';
							tk->value=0;

							sfront=insert(sfront,tk);

	       						break;	
			
	     			case IDENTIFIER: 
	       						//printf("line:%2d %15s  value = %s\n",
		      					//yylval.string_value.line_number, tokenName(tok),
		      					//yylval.string_value.value);

							tk=(struct token *)malloc(sizeof(struct token));
							sym_lineno=(struct lineno *)malloc(sizeof(struct lineno));
							sym_lineno->no=yylval.string_value.line_number;
							sym_lineno->next=NULL;

							tk->head=sym_lineno;
							tk->tail=sym_lineno;
							
	
							//tk->lineno[0]=yylval.string_value.line_number;
							tk->name=(char *)malloc(sizeof(yylval.string_value.value)+1);
							strcpy(tk->name,yylval.string_value.value);
							tk->type='I';
							tk->value=0;

							//printf("\nIdentifier:%s\tLine No:%d\n",tk->name,(tk->head)->no);
							
							sfront=insert(sfront,tk);

	       						break;
	     			case INTEGER_CONST:
	       						//printf("line:%2d %15s  value = %d\n",
		      					//yylval.integer_value.line_number,tokenName(tok),
		      					//yylval.integer_value.value);

							tk=(struct token *)malloc(sizeof(struct token));
							sym_lineno=(struct lineno *)malloc(sizeof(struct lineno));
							sym_lineno->no=yylval.integer_value.line_number;
							sym_lineno->next=NULL;

							tk->head=sym_lineno;
							tk->tail=sym_lineno;
							
	
							//tk->lineno[0]=yylval.string_value.line_number;
							tk->name=(char *)malloc(sizeof(itoa(yylval.integer_value.value))+1);
							sprintf(tk->name,"%d",yylval.integer_value.value);
							tk->type='I';
							tk->value=0;

							//printf("\nIdentifier:%s\tLine No:%d\n",tk->name,(tk->head)->no);
							
							cfront=insert(cfront,tk);

	       						break;

				case STRING_CONST:	//printf("line:%2d %15s  value = %s\n",
		      					//yylval.string_value.line_number, tokenName(tok),
		      					//yylval.string_value.value);

							tk=(struct token *)malloc(sizeof(struct token));
							sym_lineno=(struct lineno *)malloc(sizeof(struct lineno));
							sym_lineno->no=yylval.string_value.line_number;
							sym_lineno->next=NULL;

							tk->head=sym_lineno;
							tk->tail=sym_lineno;
							
							
							//tk->lineno[0]=yylval.string_value.line_number;
							tk->name=(char *)malloc(strlen(yylval.string_value.value)+1);
							strcpy(tk->name,yylval.string_value.value);
							tk->type='S';
							tk->value=0;

							//printf("\nIdentifier:%s\tLine No:%d\n",tk->name,(tk->head)->no);
							
							cfront=insert(cfront,tk);							

							break;

				case FLOAT_CONST:	//printf("line:%2d %15s  value = %s\n",
		      					//yylval.string_value.line_number, tokenName(tok),
		      					//yylval.string_value.value);

							tk=(struct token *)malloc(sizeof(struct token));
							sym_lineno=(struct lineno *)malloc(sizeof(struct lineno));
							sym_lineno->no=yylval.string_value.line_number;
							sym_lineno->next=NULL;

							tk->head=sym_lineno;
							tk->tail=sym_lineno;
							
							
							//tk->lineno[0]=yylval.string_value.line_number;
							tk->name=(char *)malloc(strlen(yylval.string_value.value)+1);
							strcpy(tk->name,yylval.string_value.value);
							tk->type='F';
							tk->value=0;

							//printf("\nIdentifier:%s\tLine No:%d\n",tk->name,(tk->head)->no);
							
							cfront=insert(cfront,tk);							

							break;

				case CHARACTER_CONST:	//printf("line:%2d %15s  value = %s\n",
		      					//yylval.string_value.line_number, tokenName(tok),
		      					//yylval.string_value.value);

							tk=(struct token *)malloc(sizeof(struct token));
							sym_lineno=(struct lineno *)malloc(sizeof(struct lineno));
							sym_lineno->no=yylval.string_value.line_number;
							sym_lineno->next=NULL;

							tk->head=sym_lineno;
							tk->tail=sym_lineno;
							
	
							//tk->lineno[0]=yylval.string_value.line_number;
							tk->name=(char *)malloc(strlen(yylval.string_value.value)+1);
							strcpy(tk->name,yylval.string_value.value);
							tk->type='C';
							tk->value=0;

							//printf("\nIdentifier:%s\tLine No:%d\n",tk->name,(tk->head)->no);
							
							cfront=insert(cfront,tk);

							break;

	     			//default:
	       						//printf("line:%2d %15s\n",yylval.line_number,tokenName(tok));
	     		}
   		}
	}		

	display(sfront,0);

	display(cfront,1);
		
	return 0;
}


#! /bin/sh


#####flag values
#0 - error
#1 - table creation
#2 - database creation
#3 - database selection
#4 - all selection
#5 - particular selection

select_columns_with_where()
{
 fields=`awk -F " " -v count=2    '{
                             while ( NF >= count )
                             {
                               if($count == "from") count=NF+1;
                               else    print $count; count+=1;
                             }
                           }' .query`
#fields contains the fields that are particularly selected from a table
#  echo $fields
  number=`awk -F " " -v count=0 '{
                                while( NF >= count)
                                 {
                                  if ($count == "from") { print count-2; count=NF+1; }
                                 else count+=1;
                                 }
                                }' .query`
#  echo $number
  tablenam=`awk -F " " -v count=2 '{
                                while ( NF >= count )
                                {
                                 if($count == "from")
                                  {
                                    count=count+1;
                                    print $count;
                                  }
                                 else count+=1;
                                }
                              }' .query`
# echo $tablenam
             awk -F ";" 'BEGIN {
                                IGNORECASE=1;
                                }
                                {
                                for(i=1;i<=NF;i++)
                                  {
                                     printf("%s",$i);
                                     if(i<=NF-1)
                                        printf(";");
                                     else
                                        printf("\n");
                                  }
                                }' $tablenam > .where
             wer=(`awk -F " " -v c="$number" 'BEGIN{c+=5;} { while(c <= NF) { if($c!="and" && $c!="or") print $c;c+=1; } }' .query`)
             wers=`awk -F " " -v c="$number" 'BEGIN{c+=5;} { while(c <= NF) { if($c!="and" && $c!="or") print $c;c+=1; } }' .query`
              #wer has the conditions after where clause
             chcks=`awk -F " " -v c=6 -v co=0 '{ while ( c<=NF ) {if($c!="or") co+=1; c+=1;}} END{print co}' .query`

             #chcks has number of columns after the where clause
             and=`awk -F " " -v c=6 'BEGIN {ands=0;ors=0; }
                                { while (c<=NF) { if($c=="and") ands=1; else if($c=="or") ors=1; c++; }}
                                END { if(ands==1 && ors==1) print "0"; else if(ands==1) print "1"; else print "2";}' .query`
            #echo $and
            #checks the and condition and makes this the correct answer to be shown to the user


            if(( $and==1  )) #and equal to 1
            then
              i=0
#              echo "inside and"
              for (( i=0;i<${#wer[@]};i++ ))
                do
                  if (( $i%3 == 0 ))
                  then

                     awk -F ";" -v f="${wer[$i]}" -v sym="${wer[$i+1]}" -v val="${wer[$i+2]}" 'BEGIN{j=0;}
                     { if(j==0) {  for(i=1;i<=NF;i++){ printf("%s", $i);if(i<NF) printf(";");  if(f == $i) place=i; }printf("\n"); j+=1; }
                       else
                       {
                       if(sym == "=" ) { if($place == val ) print $0 }
                      }
                     }' .where > .w
#cat .w
                   rm .where
                   cp .w .where
                   rm .w
                  fi
                done
           
           else #and not equal to 1
#                 echo "not and"
#                 echo $wers
#                 cat .where
                 awk -F ";" -v wer="$wers" -v chcks="$chcks" 'BEGIN { c=chcks/3;split(wer,a," "); j=0}
                                                    {
                                                    if(j==0)
                                                      {
                                                        k=0; j+=1;print $0;
                                                        for(i=1;i<=chcks;i++)
                                                          {
                                                            if(i%3==1)
                                                             { 
#                                                               printf("i : %d",i)
#                                                               printf("\n a: %s\n",a[i]);
                                                               for(l=1;l<=NF;l++)
                                                                 { #printf("^^%s **%d",$l,l);
                                                                   if(a[i]==$l)
                                                                    { field[k]=l; constrain[k]=a[i+1]; value[k]=a[i+2]; k++;}
                                                                 }
                                                             }
                                                          }
                                                      }
                                                     else
                                                     {
                                                        for(i=0;i<=c;i++)
                                                        {
                                                          if(constrain[i] == "=" )
                                                         {
                                                            if($field[i] == value[i])
                                                            { 
                                                                  for(m=1;m<=NF;m++)
                                                                { printf("%s",$m); if(m<NF)printf(";");}
                                                              printf("\n");
                                                            }
                                                          }
                                                        }
                                                      }
                                                    }' .where  > .w
                       #  cat .w
                         rm .where
                         cp .w .where
                         rm .w
            fi #and value check

#echo $fields
#echo $number
#cat .where
awk -F ";" -v array="$fields" -v nfi="$number" ' BEGIN {
                                                       j=0;
                                                       }
                                 {
                                   if(j==0)
                                    {
                                     k=0;
                                     split(array,a," ");
#                                     print NF;
                                     for(i=1;i<=NF;i++)
                                        {
                                         for(l=1;l<=nfi;l++)
                                         {
 #                                         printf("%s  ",a[l]);
                                           if(a[l]==$i)
                                            {
                                                 printf("%10s", $i);
                                                 f[k++]=i;
                                            }
                                          }
 #                                      printf("\n---------------------------------------------------------------------------------------\n");
                                        }
                                      j=j+1;
                                  printf("\n");
                                    }
                                    else
                                    {
#                                      print $f[0]
                                      for(u=0;u<k;u++)
                                        {
                                          printf("%10s", $f[u]);
                                        }
                                     printf("\n");
                                    }
                                  }' .where
#echo "printed"
}

select_columns()
{

 fields=`awk -F " " -v count=2    '{
                             while ( NF >= count )
                             {
                               if($count == "from") count=NF+1;
                               else    print $count; count+=1;
                             }
                           }' .query`
#fields contains the fields that are particularly selected from a table
# echo $fields
 number=`awk -F " " -v count=0 '{
                                while( NF >= count)
                                 {
                                  if ($count == "from") { print count-2; count=NF+1; }
                                 else count+=1;
                                 }
                                }' .query`
# echo $number
 table=`awk -F " " -v count=2 '{
                                while ( NF >= count )
                                {
                                 if($count == "from")
                                  {
                                    count=count+1;
                                    print $count;
                                  }
                                 else count+=1;
                                }
                              }' .query`
# echo $table
#table contains the table name from where the columns are to be displayed

awk -F ";" -v array="$fields" -v nfi="$number" ' BEGIN {
                                                       j=0;
                                                       }
                                 { 
                                   if(j==0)
                                    {
                                     k=0;
                                     split(array,a," ");
                                     for(i=1;i<=NF;i++)
                                        {
#                                         print i;
                                         for(l=1;l<=nfi;l++)
                                         {
                                           if(a[l]==$i)
                                            {
                                                 printf("%10s", $i);
                                                 f[k++]=i;
                                            }
                                          }
                                        }
                                      j=j+1;
                                   printf("\n\n");
                                    }
                                    else
                                    {
#                                      print $f[0]
                                      for(u=0;u<k;u++)
                                        {
                                          printf("%10s", $f[u]);
                                        }
                                     printf("\n");
                                    }
                                  }' $table



#awk -F ";" -v array="$fields" -v nfi="$number" ' BEGIN {
#                                                       j=0;
#                                                       }
#                                 {
#                                 if(j==0)
#                                  {
#                                   k=0;
#                                    split(array,a," ");
#                 	            for(i=1;i<=NF;i++)
# 					{
#                                         for(l=1;l<=nfi;l++)
#                                         {
#					   if(a[l]==$i)
# 					    {
# 						 printf("%10s", $i);
#					         f[k++]=i;
#					    }
#                                          }
#					}
#				   j=j+1;
#                                  printf("\n");
#                                  }
#                                  else
#				   {
#                                    # print $f[0]
#				     for(u=0;u<k;u++)
#				 	{
# 					  printf("%10s", $f[u]);
#					}
#                                    printf("\n");
#				   }
#                                 }
#'$table


}


#insert


uniq()
{
   flag=0;
   nor=`awk 'BEGIN{i=0;} { i++; } END{print i;}' $1`;
    for (( x=1;x<=$nor;x++ ))
       do
         str1=`awk -F ";" -v r=$x -v f=$2 ' NR == r { print $f } ' $1`; 
          for (( y=$x+1;y<=$nor;y++ ))
             do
               str2=`awk -F ";" -v r=$y -v f=$2 ' NR == r { print $f } ' $1`;
                   if [ $str1 = $str2 ]; then
                     flag=1;
                     break;         
                   fi
                   if [ $str1 = $3 ]; then
                     flag=1;
                     break;
                   fi
                   if [ $str2 = $3 ]; then
                     flag=1;
                     break;
                   fi
             done
       done
 echo $flag;
}

insert()
{
 #echo "$@";
   if [ $1 = "insert" -a $2 = "into" -a $3 = "table" ]; then
        # echo " Table Name : ";tableName="it2";
         #read -r tableName;
         tn="$4"
         tableName="$4.sch"
        #  tn=$tableName.tab;
        #  tableName=$tableName.sch;
#         echo "Tab Name : $tableName  && $tn";
#          cd $1;
#          cd $2;
       if [ -f $tableName ]; then
#         echo "Table Name $tableName";
           nr=`awk 'BEGIN{i=0;} { i++; } END{print i;}' $tableName`;
           nf=`awk -F "::" ' NR == 1 {print NF}' $tableName`; 
#           echo "NR $nr NF $nf";  
           x=1;
           while [ $x -le $nr ]
             do
              y=0;
               while [ $y -lt $nf ]
                 do
                   z=y;
                   y=`expr $y + 1`;
                   cons[z]=`awk -F "::" -v v1=$x -v v2=$y ' NR == v1  { printf("%s",$v2); }' $tableName`;
                 done
               #echo "\033[35mFIELD : ${cons[@]\033[0m}";
               echo -e "\033[35m${cons[1]} :\033[0m ";
               read -r rec[$x];
                   if [ ${cons[2]} = "y" ]; then
                     echo -e "\033[35mPK True\033[0m";
                     touch fl
                     awk -F ";" 'NR != 1 {print $0;}' $tn > fl
                     t=fl 
                    # cat fl
                     ret=$( uniq $t $x ${rec[$x]} );
                     echo $ret
                       if [ $( uniq $tn $x ${rec[$x]} )  -eq 1 ]; then
                          echo -e "\033[35mDuplicate entry\033[0m";
                          exit;
                       fi
                   fi
                   if [ ${cons[3]} = "y" ]; then
                     echo -e "\033[35mFK true\033[0m"; # chk with the table
                   fi 
                   if [ ${cons[4]} = "y" ]; then
                      if [ ${rec[$x]} = "" ]; then
                         echo -e "\033[33mAttempt to insert NULL value\033[0m";
                         exit;
                      fi  
                   fi 
                   if [ ${cons[5]} = "y" ]; then
                      ret=$( uniq $tn $x ${rec[$x]} );
                       if [ $ret -eq 1 ]; then
                          echo -e "\033[33mDuplicate entry\033[0m";
                          #exit;
                        fi
                   fi

                   if [ ${cons[6]} != "n" -a ${cons[4]} == "y" ]; then
                      if [ ${rec[$x]} = "" ]; then
                         echo -e "\033[33mDefault value inserted\033[0m";
                         ${rec[$x]}=${cons[6]};
                      fi
                   fi        

                   chk=`echo "${cons[7]}" | awk -F ":" ' { print $1 } '`;
                   if [ $chk != "n" ]; then
                      cv=`echo "${cons[7]}" | awk -F ":" ' { print $2 } '`;
                        if [ ${rec[$x]} -$chk $cv ]; then
                           echo "";
                        else
                           echo -e "\033[33mInvalid FIELD Value\033[0m";   
                        fi          
                   fi
               #echo "x : $x";
               #read -r 
               x=`expr $x + 1`; 
             done         
        record="";  
          for (( w=1;w<=$nr;w++ ))
             do
              if (( $w<$nr ))
              then
               record="$record${rec[$w]};";
              else
               record="$record${rec[$w]}"; 
             fi
             done
          echo "$record" | cat >> $tn;
         echo -e "\033[34mValue inserted Successfully\033[0m" 
        echo " "  
      else
          echo -e "\n\033[35m Table doesn't exists !! \033[0m";  
      fi
   fi

# cd ~/Package/ipac/ipac;
}




#create table

createTable() 
{
#  echo "$@";
  if [ $2 = "create" -a $3 = "table" ]; then
  #    echo "Table Name : ";
    #  read -r tableName;
   tableName="$1"
    if [ -f $tableName.sch ]; then
      echo "Table already exists !!"; pp=1;
    else
#      cd $1;
#      cd $2; 
        touch $tableName.sch # Schema
        touch $tableName # Data
      echo -e "\033[35m No.. of Fields : \033[0m";
      read -r nf;
       x=1;
      fields=""
         while [ $x -le $nf ]
          do
            echo -e "\033[35m Field $x : \033[0m"; #PK ForeignKey NotNULL Unique Default Check DataType ";
            read -r fld ;
              echo -e "\033[35m Primary Key : \033[0m";
              read -r pk;
              echo -e "\033[35m Foreign Key : \033[0m";
              read -r fk;
                if [ $pk = "y" ]; then
                    uq="y";
                    nn="y";
                    df="n";
                else
                   echo -e "\033[35m Unique      :  \033[0m";
                   read -r uq;
                     if [ $uq = "y" ]; then
                         nn="y";
                         df="n";
                     else
                         echo -e "\033[35m Not NULL    : \033[0m";
                         read -r nn;
                         echo -e "\033[35m Default     : \033[0m";
                         read -r df;
                              if [ $df = "y" ]; then
                                 echo -e " \033[35m Default value : \033[0m";
                                 read -r df;
                              fi
                     fi
                fi
              echo -e "\033[35m Data Type   : \033[0m";
              read -r dt;
              if [ $dt = "int" ]; then
                  echo -e "Check       : ";
                  read -r ch;
                     if [ $ch = "y" ]; then
                        echo -e "\033[35m Less than or greater than or equal [lt , gt , le, ge] \033[0m";
                        read -r cons;
                        echo -e "\033[35m Value : \033[0m"
                        read -r cv;
                        ch="$cons:$cv";
                     fi
               else
                   ch="n";
               fi
               rec=" "; 
               rec="$fld::$pk::$fk::$nn::$uq::$df::$ch::$dt";
             if (( $x < $nf ))
             then
                fields="$fields$fld;";
             else
                fields="$fields$fld";
             fi
                 echo "$rec" >> $tableName.sch ;

               #if [ $x -eq $nf ];thenrec="$rec$x";else rec="$rec$x::";fi #echo"$f::">>$tableName
             x=`expr $x + 1`;
          done     #echo "$rec" >> $tableName.sch
           echo $fields > $tableName
           echo -e "\033[33m Table Created Successfully \033[0m "
    fi
  fi
}


#main function

clear
query="f"
databaseSelected=0
touch .query
 while  [ $query != "exit" ]
 do
 read query
 echo $query | cat > .query
 q="$query"
 query=`awk -F " " '{ print $1 }' .query`
 flag=`awk -F " " '$1=="create"{
                              if($2=="table")
                                    print 1;
                              else if($2=="database")
                                    print 2;
                              else
                                    print 0;
                              }
                   $1=="select"{
                               if($2=="database")
                                     print 3;
                               else if($2=="all")
                                     print 4;
                               else
                                     print 5;
                              }
                  $1=="insert" && $2=="into" && $3=="table" {print 6}
                  ' .query`

if [[ -z $flag  ]]
then
    echo > /dev/null
else
    #create table or database
    if (( $flag ==1 || $flag ==2 ))
    then
       name=`awk -F " " '{ print $3 }' .query`
       if [[ -z $name ]]
       then
          echo > /dev/null
       else
           #table creation inside selected database
           if (( $flag == 1 && $databaseSelected==1 ))
           then
#           echo "inside"
           createTable $name $q
          #   touch $name
             echo ""
             
           fi
           #database not selected for creating tables
           if (( $flag == 1 && $databaseSelected == 0 ))
           then
              echo -e "\033[33m Sorry ! You have to select a Database inorder to create tables \033[0m"
              echo ""
           fi
           #database creation
           if (( $flag == 2 && $databaseSelected == 0 ))
           then
              mkdir $name
              echo -e "\033[34m Database Created Successfully \033[0m "
              echo ""
           fi

       fi
    fi

    # select database or table
    if (( $flag ==3 || $flag ==4 || $flag ==5  ))
    then
       if (( $flag == 3 )) # select databse - check
       then
          if (( $databaseSelected == 0 )) # database flag - check
          then
             name=`awk -F " " '$2=="database" { print $3 }' .query`
             if [[ -z $name ]] #check if proper name is given for database
             then
                echo > /dev/null
             else
                #####check if there is a database of that type
              if [ -d $name ] #database exist
              then
                databaseSelected=1;
                cd $name
                echo -e "\033[34m $name - database has been selected \033[0m"
                echo ""
              else
                echo -e "\033[33m Sorry No Such database Exist ! \033[0m" 
                echo " "
               fi #database exist
             fi   #proper name given for select
          else
             if (( $databaseSelected == 1  ))
             then
                echo " A Database has already been selected "
                echo ""
             fi
          fi    # database flag - check
       fi       # select database - chck
       if (( $flag==4 ))  #select all statement
       then
          tablename=`awk -F " " '$3=="from" && $5 != "where" { print $4 }' .query`
#          echo $tablename
          ##### check if there is a table of that name
          if [[  -z $tablename ]] #where  there
          then
#             echo " Where clause present"
             tablename=`awk -F " " '$3=="from" && $5 == "where" { print $4 }' .query`
#             echo $tablename
            if [[ -f $tablename ]]
            then
              awk -F ";" 'BEGIN {
				IGNORECASE=1;
				}
				{
                                for(i=1;i<=NF;i++)
                                  {
				     printf("%s",$i);
                                     if(i<=NF-1)
                                        printf(";");
                                     else
					printf("\n");
                                  }
				}' $tablename > .where

            wer=(`awk -F " " -v c=6 ' { while(c <= NF) { if($c!="and" && $c!="or") print $c;c+=1; } }' .query`)
            wers=`awk -F " " -v c=6 ' { while(c <= NF) { if($c!="and" && $c!="or") print $c;c+=1; } }' .query`
            #wer has the conditions after where clause
            chcks=`awk -F " " -v c=6 -v co=0 '{ while ( c<=NF ) {if($c!="or") co+=1; c+=1;}} END{print co}' .query`
             #chcks has number of columns after the where clause
            and=`awk -F " " -v c=6 'BEGIN {ands=0;ors=0; }
                                { while (c<=NF) { if($c=="and") ands=1; else if($c=="or") ors=1; c++; }}
                                END{if(ands==1 && ors==1) print "0"; else if(ands==1) print "1"; else print "2";}' .query`
#            echo $and
            #checks the and condition and makes this the correct answer to be shown to the user
            if(( $and==1  )) #and equal to 1
            then
              i=0
              for (( i=0;i<${#wer[@]};i++ ))
                do
                  if (( $i%3 == 0 ))
                  then

                     awk -F ";" -v f="${wer[$i]}" -v sym="${wer[$i+1]}" -v val="${wer[$i+2]}" 'BEGIN{j=0;}
                     { if(j==0) { print $0; for(i=1;i<=NF;i++) { if(f == $i) place=i; } j+=1; }
                       else
                       {
                       if(sym == "=" ) { if($place == val ) print $0 }
                      }
                     }' .where > .w
                   rm .where
                   cp .w .where
                  rm .w
                  fi
                 done
#                   cat .where
                   awk -F ";" '{ for(i=1;i<=NF;i++) printf("%10s",$i); printf("\n"); }' .where 
                  
                

           else #and not equal to 1
                awk -F ";" -v wer="$wers" -v chcks="$chcks" 'BEGIN { c=chcks/3;split(wer,a," "); j=0}
                                                    {
						     if(j==0)
                                                      {
                                                        k=0; j+=1;
                                                        for(i=1;i<=chcks;i++)
                                                          {
                                                            if( i%3==1)
                                                             { 
#								printf("i : %d",i)
#                                                               printf("\n a: %s\n",a[i]);
                                                               for(l=1;l<=NF;l++)
                                                                 { #printf("^^%s **%d",$l,l);
                                                                   if(a[i]==$l)
                                                                    { field[k]=l; constrain[k]=a[i+1]; value[k]=a[i+2]; k++;}
                                                                 }
                                                             }
                                                          }
                                                      }
                                                     else
						     {
							for(i=0;i<c;i++)
						{
							  if(constrain[i] == "=" )
                                                         {
							    if($field[i] == value[i])
                                                            { for(m=1;m<=NF;m++)
                                                                 printf("%10s",$m);
                                                              printf("\n");
                                                            }
							  }
							}
						     }
						    }
 	 					    ' .where 
            fi #and value check
           else
                echo -e "\033[34m Table does not exist \033[0m";
           fi
          else #where not there
           if [[ -f $tablename  ]]
          then
             awk -F ";" 'BEGIN {
                               IGNORECASE=1;
                                }
                                {
                                for(i=1;i<=NF;i++)
                                   printf ("%15s",$i);
                                printf("\n");
                                }
                            END {
                                printf ("\n");
                                }' $tablename
           else 
               echo -e "\033[34m Table does not exist \033[0m"
           fi
         fi
      fi #select all statement
      if (( $flag == 5 && $databaseSelected==1 ))
      then
        where_flag=`awk -F " " -v count=2 'BEGIN{ flag=0; }{ while (count <= NF) { if($count == "where") flag=1; count+=1; }}END { if(flag==1) print 1; else print 0;}' .query`
#       echo $where_flag
        if (( $where_flag==1 ))
        then
          select_columns_with_where
        else
          select_columns
        fi
     fi
  fi             # select database or table
 if (( $flag==6 ))
 then
 insert $q
 fi 
fi               # if query check after setting flags
done             # while~

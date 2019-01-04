---
title: MySQL Primer - Source Code
---

This article introduce MySQL source code layouts and internals.

<!--more-->

## Table of Contents

* TOC
{:toc}

## Setup

### Getting the Source Tree

```console
[oxnz@localhost mysql-server]$ git clone https://github.com/mysql/mysql-server.git --depth=1
[oxnz@localhost mysql-server]$ cd mysql-server
[oxnz@localhost mysql-server]$ git br
* 5.7
```

#### Source Code Layout

```console
[oxnz@localhost mysql-server]$ ls -l
total 312
drwxrwxr-x.  2 oxnz oxnz  4096 Nov  9 09:53 BUILD
drwxrwxr-x.  6 oxnz oxnz  4096 Nov  9 09:53 client
drwxrwxr-x.  4 oxnz oxnz  4096 Nov  9 09:53 cmake
-rw-rw-r--.  1 oxnz oxnz 24979 Nov  9 09:53 CMakeLists.txt
drwxrwxr-x.  3 oxnz oxnz    20 Nov  9 09:53 cmd-line-utils
-rw-rw-r--.  1 oxnz oxnz 13882 Nov  9 09:53 config.h.cmake
-rw-rw-r--.  1 oxnz oxnz 31020 Nov  9 09:53 configure.cmake
-rw-rw-r--.  1 oxnz oxnz 17987 Nov  9 09:53 COPYING
drwxrwxr-x.  2 oxnz oxnz  4096 Nov  9 09:53 dbug
drwxrwxr-x.  2 oxnz oxnz    62 Nov  9 09:53 Docs
-rw-rw-r--.  1 oxnz oxnz 66241 Nov  9 09:53 Doxyfile-perfschema
drwxrwxr-x.  6 oxnz oxnz  4096 Nov  9 09:53 extra
drwxrwxr-x.  5 oxnz oxnz  4096 Nov  9 09:53 include
-rw-rw-r--.  1 oxnz oxnz   333 Nov  9 09:53 INSTALL
drwxrwxr-x.  5 oxnz oxnz  4096 Nov  9 09:53 libbinlogevents
drwxrwxr-x.  3 oxnz oxnz    37 Nov  9 09:53 libbinlogstandalone
drwxrwxr-x.  7 oxnz oxnz  4096 Nov  9 09:53 libevent
drwxrwxr-x.  3 oxnz oxnz  4096 Nov  9 09:53 libmysql
drwxrwxr-x.  3 oxnz oxnz  4096 Nov  9 09:53 libmysqld
drwxrwxr-x.  2 oxnz oxnz  4096 Nov  9 09:53 libservices
drwxrwxr-x.  2 oxnz oxnz    44 Nov  9 09:53 man
drwxrwxr-x. 10 oxnz oxnz  4096 Nov  9 09:53 mysql-test
drwxrwxr-x.  2 oxnz oxnz  4096 Nov  9 09:53 mysys
drwxrwxr-x.  2 oxnz oxnz  4096 Nov  9 09:53 mysys_ssl
drwxrwxr-x.  9 oxnz oxnz  4096 Nov  9 09:53 packaging
drwxrwxr-x. 17 oxnz oxnz  4096 Nov  9 09:53 plugin
drwxrwxr-x.  4 oxnz oxnz    34 Nov  9 09:53 rapid
-rw-rw-r--.  1 oxnz oxnz  2478 Nov  9 09:53 README
drwxrwxr-x.  2 oxnz oxnz  4096 Nov  9 09:53 regex
drwxrwxr-x.  3 oxnz oxnz  4096 Nov  9 09:53 scripts
drwxrwxr-x.  7 oxnz oxnz 20480 Nov  9 09:53 sql
drwxrwxr-x.  2 oxnz oxnz  4096 Nov  9 09:53 sql-common
drwxrwxr-x. 14 oxnz oxnz  4096 Nov  9 09:53 storage
drwxrwxr-x.  2 oxnz oxnz  4096 Nov  9 09:53 strings
drwxrwxr-x.  4 oxnz oxnz  4096 Nov  9 09:53 support-files
drwxrwxr-x.  2 oxnz oxnz    94 Nov  9 09:53 testclients
drwxrwxr-x.  5 oxnz oxnz    66 Nov  9 09:53 unittest
-rw-rw-r--.  1 oxnz oxnz    88 Nov  9 09:53 VERSION
drwxrwxr-x.  3 oxnz oxnz  4096 Nov  9 09:53 vio
drwxrwxr-x.  2 oxnz oxnz    31 Nov  9 09:53 win
drwxrwxr-x.  2 oxnz oxnz  4096 Nov  9 09:53 zlib
```

#### Layout Brief

* /Users/oxnz/Developer/mysql-5.7.11/sql/sql_delete.h 
* /Users/oxnz/Developer/mysql-5.7.11/sql/sql_delete.cc
* vio: virtual I/O
    * wrappers for the various network I/O calls that happen with deifferent protocols

#### Flow

```
User enters 'INSERT' statement /* client */
|
Message goes over TCP/IP line /* vio, various */
|
Server parses statement /* sql */
|
Server calls low-level functions /* myisam */
|
Handler stores in file /* mysys */
```

### Build

#### CMake

modify `BUILD/compile-pentium-debug` to download boost automatically:

```shell
#!/bin/sh
path=`dirname $0`
cmake $path/.. -DWITH_DEBUG=1 -DDOWNLOAD_BOOST=1 -DWITH_BOOST=../boost
make
```

run build script:

```shell
./BUILD/compile-pentimu-debug --prefix=$HOME/mysql-bin
make
make install
$HOME/mysql-bin/scripts/mysql_install_db \
    --basedir=$HOME/mysql-bin \
    --datadir=$HOME/mysql-bin/var
```

#### Alternative

```shell
CFLAGS='-g -O0'
CXX=gcc
CXXFLAGS='-g -O0 -felide-constructors -fno-exceptions -fno-rtti'
./configure --prefix=/home/oxnz/mysql \
    --with-extra-charsets=complex \
    --enable-thread-safe-client \
    --enable-local-infile  \
    --enable-assembler \
    --with-plugins=innobase \
    --with-fast-mutexes
make
make install
```

### Env

```shell
groupadd mysql
useradd mysql -g mysql
```

### Running in DEBUG Mode

>
To run a test named some.test with the debugger in embedded mode you could do this:
>
* Run libmysqld/examples/test_run --gdb some.test. This creates a libmysqld/examples/test-gdbinit file which contains the required parameters for mysqltest.
* Make a copy of the test-gdbinit file (call it, for example, some-gdbinit). The test-gdbinit file will be removed after test-run --gdb has finished.
* Load libmysqld/examples/mysqltest_embedded into your favorite debugger, for example: gdb mysqltest_embedded.
* In the debugger, for example in gdb, do: --sou some-gdbinit

## MySQL

### Base Classes

`sql/sql_class.h`

```console
[oxnz@rmbp:mysql-5.7.11:0]$ grep '^class.*[^;]$' sql/sql_class.h 
class CSET_STRING
class Key_part_spec :public Sql_alloc {
class Key :public Sql_alloc {
class Foreign_key: public Key {
class thd_scheduler
class Query_arena
class Prepared_statement_map
class Item_change_record: public ilink<Item_change_record>
class Open_tables_state
class Open_tables_backup: public Open_tables_state
class Sub_statement_state
class Internal_error_handler
class Dummy_error_handler : public Internal_error_handler
class Drop_table_error_handler : public Internal_error_handler
class MDL_deadlock_and_lock_abort_error_handler: public Internal_error_handler
class Locked_tables_list
class Global_read_lock
class THD :public MDL_context_owner,
class Prepared_stmt_arena_holder
class sql_exchange :public Sql_alloc
class Query_result :public Sql_alloc {
class Query_result_interceptor: public Query_result
class Query_result_send :public Query_result {
class Query_result_to_file :public Query_result_interceptor {
class Query_result_export :public Query_result_to_file {
class Query_result_dump :public Query_result_to_file {
class Temp_table_param :public Sql_alloc
class Query_result_subquery :public Query_result_interceptor
class Table_ident :public Sql_alloc
class user_var_entry
class Query_dumpvar :public Query_result_interceptor {
```

### class THD

```cpp
/**                                                                             
  @class THD                                                                    
  For each client connection we create a separate thread with THD serving as    
  a thread/connection descriptor                                                
*/                                                                              
                                                                                
class THD :public MDL_context_owner,                                            
           public Query_arena,                                                  
           public Open_tables_state                                             
{                                                                               
private:                                                                        
  inline bool is_stmt_prepare() const                                           
  { DBUG_ASSERT(0); return Query_arena::is_stmt_prepare(); }                    
                                                                                
  inline bool is_stmt_prepare_or_first_sp_execute() const                       
  { DBUG_ASSERT(0); return Query_arena::is_stmt_prepare_or_first_sp_execute(); }
                                                                                
  inline bool is_stmt_prepare_or_first_stmt_execute() const                     
  { DBUG_ASSERT(0); return Query_arena::is_stmt_prepare_or_first_stmt_execute(); }
                                                                                
  inline bool is_conventional() const                                           
  { DBUG_ASSERT(0); return Query_arena::is_conventional(); } 
public:                                                                         
  MDL_context mdl_context;                                                      
                                                                                
  /*                                                                            
    MARK_COLUMNS_NONE:  Means mark_used_colums is not set and no indicator to   
                        handler of fields used is set                           
    MARK_COLUMNS_READ:  Means a bit in read set is set to inform handler        
                        that the field is to be read. Update covering_keys      
                        and merge_keys too.                                     
    MARK_COLUMNS_WRITE: Means a bit is set in write set to inform handler       
                        that it needs to update this field in write_row         
                        and update_row. If field list contains duplicates,      
                        then thd->dup_field is set to point to the last         
                        found duplicate.                                        
    MARK_COLUMNS_TEMP:  Mark bit in read set, but ignore key sets.              
                        Used by filesort().                                     
  */                                                                            
  enum enum_mark_columns mark_used_columns;                                     
  /**                                                                           
    Used by Item::check_column_privileges() to tell which privileges            
    to check for.                                                               
    Set to ~0ULL before starting to resolve a statement.                        
    Set to desired privilege mask before calling a resolver function that will  
    call Item::check_column_privileges().                                       
    After use, restore previous value as current value.                         
  */                                                                            
  ulong want_privilege;                                                         
                                                                                
  LEX *lex;                                     // parse tree descriptor        
                                                                                
  /*                                                                            
   True if @@SESSION.GTID_EXECUTED was read once and the deprecation warning    
   was issued.                                                                  
   This flag needs to be removed once @@SESSION.GTID_EXECUTED is deprecated.    
  */                                                                            
  bool gtid_executed_warning_issued;
private:                                                                        
  /**                                                                           
    The query associated with this statement.                                   
  */                                                                            
  LEX_CSTRING m_query_string;                                                   
  String m_normalized_query;                                                    
                                                                                
  /**                                                                           
    Currently selected catalog.                                                 
  */                                                                            
                                                                                
  LEX_CSTRING m_catalog;                                                        
  /**                                                                           
    Name of the current (default) database.                                     
                                                                                
    If there is the current (default) database, "db" contains its name. If      
    there is no current (default) database, "db" is NULL and "db_length" is     
    0. In other words, "db", "db_length" must either be NULL, or contain a      
    valid database name.                                                        
                                                                                
    @note this attribute is set and alloced by the slave SQL thread (for        
    the THD of that thread); that thread is (and must remain, for now) the      
    only responsible for freeing this member.                                   
  */                                                                            
  LEX_CSTRING m_db;                                                             
                                                                                
public:                                                                         
                                                                                
  /**                                                                           
    In some cases, we may want to modify the query (i.e. replace                
    passwords with their hashes before logging the statement etc.).             
                                                                                
    In case the query was rewritten, the original query will live in            
    m_query_string, while the rewritten query lives in rewritten_query.         
    If rewritten_query is empty, m_query_string should be logged.               
    If rewritten_query is non-empty, the rewritten query it contains            
    should be used in logs (general log, slow query log, binary log).           
                                                                                
    Currently, password obfuscation is the only rewriting we do; more           
    may follow at a later date, both pre- and post parsing of the query.        
    Rewriting of binloggable statements must preserve all pertinent             
    information.                                                                
  */                                                                            
  String      rewritten_query;                                                  
                                                                                
  /* Used to execute base64 coded binlog events in MySQL server */              
  Relay_log_info* rli_fake;                                                     
  /* Slave applier execution context */                                         
  Relay_log_info* rli_slave;
                                                                                
  /**                                                                           
    The function checks whether the thread is processing queries from binlog,   
    as automatically generated by mysqlbinlog.                                  
                                                                                
    @return true  when the thread is a binlog applier                           
  */                                                                            
  bool is_binlog_applier() { return rli_fake && variables.pseudo_slave_mode; }  
                                                                                
  /**                                                                           
    @return true  when the thread is binlog applier.                            
    @note When the thread is a binlog applier it memorizes a fact of that it    
          has detached "native" engine transactions associated with it.         
  */                                                                            
  bool binlog_applier_need_detach_trx();                                        
                                                                                
  /**                                                                           
    @return true   when the binlog applier (rli_fake) thread has detached       
                   "native" engine transaction, see @c binlog_applier_detach_trx.
    @note The binlog applier having detached transactions resets a memo         
          mark at once with this check.                                         
  */                                                                            
  bool binlog_applier_has_detached_trx();                                       
  void reset_for_next_command();                                                
  /*                                                                            
    Constant for THD::where initialization in the beginning of every query.     
                                                                                
    It's needed because we do not save/restore THD::where normally during       
    primary (non subselect) query execution.                                    
  */                                                                            
  static const char * const DEFAULT_WHERE;                                      
                                                                                
#ifdef EMBEDDED_LIBRARY                                                         
  struct st_mysql  *mysql;                                                      
  unsigned long  client_stmt_id;                                                
  unsigned long  client_param_count;                                            
  struct st_mysql_bind *client_params;                                          
  char *extra_data;                                                             
  ulong extra_length;                                                           
  struct st_mysql_data *cur_data;                                               
  struct st_mysql_data *first_data;                                             
  struct st_mysql_data **data_tail;                                             
  void clear_data_list();                                                       
  struct st_mysql_data *alloc_new_dataset();                                    
  /*                                                                            
    In embedded server it points to the statement that is processed             
    in the current query. We store some results directly in statement           
    fields then.                                                                
  */                                                                            
  struct st_mysql_stmt *current_stmt;                                           
#endif                                                                          
  Query_cache_tls query_cache_tls;                                              
  /** Aditional network instrumentation for the server only. */                 
  NET_SERVER m_net_server_extension;                                            
  /**                                                                           
    Hash for user variables.
    User variables are per session,                                             
    but can also be monitored outside of the session,                           
    so a lock is needed to prevent race conditions.                             
    Protected by @c LOCK_thd_data.                                              
  */                                                                            
  HASH    user_vars;            // hash for user variables                      
  String  convert_buffer;               // buffer for charset conversions       
  struct  rand_struct rand;     // used for authentication                      
  struct  system_variables variables;   // Changeable local variables           
  struct  system_status_var status_var; // Per thread statistic vars            
  struct  system_status_var *initial_status_var; /* used by show status */      
  // has status_var already been added to global_status_var?                    
  bool status_var_aggregated;                                                   
                                                                                
  /**                                                                           
    Current query cost.                                                         
    @sa system_status_var::last_query_cost                                      
  */                                                                            
  double m_current_query_cost;                                                  
  /**                                                                           
    Current query partial plans.                                                
    @sa system_status_var::last_query_partial_plans                             
  */                                                                            
  ulonglong m_current_query_partial_plans;                                      
                                                                                
  /**                                                                           
    Clear the query costs attributes for the current query.                     
  */                                                                            
  void clear_current_query_costs()                                              
  {                                                                             
    m_current_query_cost= 0.0;                                                  
    m_current_query_partial_plans= 0;                                           
  }                                                                             
                                                                                
  /**                                                                           
    Save the current query costs attributes in                                  
    the thread session status.                                                  
    Use this method only after the query execution is completed,                
    so that                                                                     
      @code SHOW SESSION STATUS like 'last_query_%' @endcode                    
      @code SELECT * from performance_schema.session_status                     
      WHERE VARIABLE_NAME like 'last_query_%' @endcode                          
    actually reports the previous query, not itself.                            
  */                                                                            
  void save_current_query_costs()                                               
  {                                                                             
    status_var.last_query_cost= m_current_query_cost;                           
    status_var.last_query_partial_plans= m_current_query_partial_plans;         
  }                                                                             
                                                                                
  THR_LOCK_INFO lock_info;              // Locking info of this thread          
  /**                                                                           
    Protects THD data accessed from other threads.                              
    The attributes protected are:                                               
    - thd->is_killable (used by KILL statement and shutdown).                   
    - thd->user_vars (user variables, inspected by monitoring)
    Is locked when THD is deleted.                                              
  */                                                                            
  mysql_mutex_t LOCK_thd_data;                                                  
                                                                                
  /**                                                                           
    Protects THD::m_query_string. No other mutexes should be locked             
    while having this mutex locked.                                             
  */                                                                            
  mysql_mutex_t LOCK_thd_query;                                                 
                                                                                
  /**                                                                           
    Protects THD::variables while being updated. This should be taken inside    
    of LOCK_thd_data and outside of LOCK_global_system_variables.               
  */                                                                            
  mysql_mutex_t LOCK_thd_sysvar;                                                
                                                                                
  /**                                                                           
    Protects query plan (SELECT/UPDATE/DELETE's) from being freed/changed       
    while another thread explains it. Following structures are protected by     
    this mutex:                                                                 
      THD::Query_plan                                                           
      Modification_plan                                                         
      SELECT_LEX::join                                                          
      JOIN::plan_state                                                          
      Tree of SELECT_LEX_UNIT after THD::Query_plan was set till                
        THD::Query_plan cleanup                                                 
      JOIN_TAB::select->quick                                                   
    Code that changes objects above should take this mutex.                     
    Explain code takes this mutex to block changes to named structures to       
    avoid crashes in following functions:                                       
      explain_single_table_modification                                         
      explain_query                                                             
      mysql_explain_other                                                       
    When doing EXPLAIN CONNECTION:                                              
      all explain code assumes that this mutex is already taken.                
    When doing ordinary EXPLAIN:                                                
      the mutex does need to be taken (no need to protect reading my own data,  
      moreover EXPLAIN CONNECTION can't run on an ordinary EXPLAIN).            
  */                                                                            
private:                                                                        
  mysql_mutex_t LOCK_query_plan;                                                
                                                                                
public:                                                                         
  /// Locks the query plan of this THD                                          
  void lock_query_plan() { mysql_mutex_lock(&LOCK_query_plan); }                
  void unlock_query_plan() { mysql_mutex_unlock(&LOCK_query_plan); }            
                                                                                
  /** All prepared statements of this connection. */                            
  Prepared_statement_map stmt_map;                                              
  /*                                                                            
    A pointer to the stack frame of handle_one_connection(),                    
    which is called first in the thread for handling a client                   
  */                                                                            
  const char *thread_stack;
                                                                                
  /**                                                                           
    @note                                                                       
    Some members of THD (currently 'Statement::db',                             
    'catalog' and 'query')  are set and alloced by the slave SQL thread         
    (for the THD of that thread); that thread is (and must remain, for now)     
    the only responsible for freeing these 3 members. If you add members        
    here, and you add code to set them in replication, don't forget to          
    free_them_and_set_them_to_0 in replication properly. For details see        
    the 'err:' label of the handle_slave_sql() in sql/slave.cc.                 
                                                                                
    @see handle_slave_sql                                                       
  */                                                                            
                                                                                
  Security_context m_main_security_ctx;                                         
  Security_context *m_security_ctx;                                             
                                                                                
  Security_context* security_context() const { return m_security_ctx; }         
  void set_security_context(Security_context *sctx) { m_security_ctx= sctx; }   
                                                                                
  /*                                                                            
    Points to info-string that we show in SHOW PROCESSLIST                      
    You are supposed to update thd->proc_info only if you have coded            
    a time-consuming piece that MySQL can get stuck in for a long time.         
                                                                                
    Set it using the  thd_proc_info(THD *thread, const char *message)           
    macro/function.                                                             
                                                                                
    This member is accessed and assigned without any synchronization.           
    Therefore, it may point only to constant (statically                        
    allocated) strings, which memory won't go away over time.                   
  */                                                                            
  const char *proc_info;                                                        
                                                                                
  Protocol_text   protocol_text;    // Normal protocol                          
  Protocol_binary protocol_binary;  // Binary protocol                          
                                                                                
  Protocol *get_protocol()                                                      
  {                                                                             
    return m_protocol;                                                          
  }                                                                             
                                                                                
  /**                                                                           
    Asserts that the protocol is of type text or binary and then                
    returns the m_protocol casted to Protocol_classic. This method              
    is needed to prevent misuse of pluggable protocols by legacy code           
  */                                                                            
  Protocol_classic *get_protocol_classic() const                                
  {                                                                             
    DBUG_ASSERT(m_protocol->type() == Protocol::PROTOCOL_TEXT ||                
                m_protocol->type() == Protocol::PROTOCOL_BINARY);               
                                                                                
    return (Protocol_classic *) m_protocol;                                     
  }
```

### Connection

`sql/sql_connect.h`

```cpp
/*                                                                              
  This structure specifies the maximum amount of resources which                
  can be consumed by each account. Zero value of a member means                 
  there is no limit.                                                            
*/                                                                              
typedef struct user_resources {                                                 
  /* Maximum number of queries/statements per hour. */                          
  uint questions;                                                               
  /*                                                                            
     Maximum number of updating statements per hour (which statements are       
     updating is defined by sql_command_flags array).                           
  */                                                                            
  uint updates;                                                                 
  /* Maximum number of connections established per hour. */                     
  uint conn_per_hour;                                                           
  /* Maximum number of concurrent connections. */                               
  uint user_conn;                                                               
  /*                                                                            
     Values of this enum and specified_limits member are used by the            
     parser to store which user limits were specified in GRANT statement.       
  */                                                                            
  enum {QUERIES_PER_HOUR= 1, UPDATES_PER_HOUR= 2, CONNECTIONS_PER_HOUR= 4,      
        USER_CONNECTIONS= 8};                                                   
  uint specified_limits;                                                        
} USER_RESOURCES;

/*                                                                              
  This structure is used for counting resources consumed and for checking       
  them against specified user limits.                                           
*/                                                                              
typedef struct user_conn {                                                      
  /*                                                                            
     Pointer to user+host key (pair separated by '\0') defining the entity      
     for which resources are counted (By default it is user account thus        
     priv_user/priv_host pair is used. If --old-style-user-limits option        
     is enabled, resources are counted for each user+host separately).          
  */                                                                            
  char *user;                                                                   
  /* Pointer to host part of the key. */                                        
  char *host;                                                                   
  /**                                                                           
     The moment of time when per hour counters were reset last time             
     (i.e. start of "hour" for conn_per_hour, updates, questions counters).     
  */                                                                            
  ulonglong reset_utime;                                                        
  /* Total length of the key. */                                                
  size_t len;                                                                   
  /* Current amount of concurrent connections for this account. */              
  uint connections;                                                             
  /*                                                                            
     Current number of connections per hour, number of updating statements      
     per hour and total number of statements per hour for this account.         
  */                                                                            
  uint conn_per_hour, updates, questions;                                       
  /* Maximum amount of resources which account is allowed to consume. */        
  USER_RESOURCES user_resources;                                                
} USER_CONN;

void init_max_user_conn(void);                                                  
void free_max_user_conn(void);                                                  
void reset_mqh(LEX_USER *lu, bool get_them);                                    
bool check_mqh(THD *thd, uint check_command);                                   
void decrease_user_connections(USER_CONN *uc);                                  
void release_user_connection(THD *thd);                                         
bool thd_init_client_charset(THD *thd, uint cs_number);                         
bool thd_prepare_connection(THD *thd);                                          
void close_connection(THD *thd, uint sql_errno= 0, bool server_shutdown= false);
bool thd_connection_alive(THD *thd);                                            
void end_connection(THD *thd);                                                  
int get_or_create_user_conn(THD *thd, const char *user,                         
                            const char *host, const USER_RESOURCES *mqh);       
int check_for_max_user_connections(THD *thd, const USER_CONN *uc);
```

### Memory

`include/my_alloc.h`

```cpp
typedef struct st_used_mem                                                      
{                  /* struct for once_alloc (block) */                          
  struct st_used_mem *next;    /* Next block in use */                          
  unsigned int  left;          /* memory left in block  */                      
  unsigned int  size;          /* size of block */                              
} USED_MEM;                                                                     
                                                                                
                                                                                
typedef struct st_mem_root                                                      
{                                                                               
  USED_MEM *free;                  /* blocks with free memory in it */          
  USED_MEM *used;                  /* blocks almost without free memory */      
  USED_MEM *pre_alloc;             /* preallocated block */                     
  /* if block have less memory it will be put in 'used' list */                 
  size_t min_malloc;                                                            
  size_t block_size;               /* initial block size */                     
  unsigned int block_num;          /* allocated blocks counter */               
  /*                                                                            
     first free block in queue test counter (if it exceed                       
     MAX_BLOCK_USAGE_BEFORE_DROP block will be dropped in 'used' list)          
  */                                                                            
  unsigned int first_block_usage;                                               
                                                                                
  /*                                                                            
    Maximum amount of memory this mem_root can hold. A value of 0               
    implies there is no limit.                                                  
  */                                                                            
  size_t max_capacity;                                                          
                                                                                
  /* Allocated size for this mem_root */                                        
                                                                                
  size_t allocated_size;                                                        
                                                                                
  /* Enable this for error reporting if capacity is exceeded */                 
  my_bool error_for_capacity_exceeded;                                          
                                                                                
  void (*error_handler)(void);                                                  
                                                                                
  PSI_memory_key m_psi_key;                                                     
} MEM_ROOT;
```

### Procedure

#### `sql/main.cc`

```cpp
/*                                                                              
  main() for mysqld.                                                            
  Calls mysqld_main() entry point exported by sql library.                      
*/                                                                              
extern int mysqld_main(int argc, char **argv);                                  
                                                                                
int main(int argc, char **argv)                                                 
{                                                                               
  return mysqld_main(argc, argv);                                               
}
```

#### `sql/mysqld.cc`

```cpp
#ifdef _WIN32                                                                   
int win_main(int argc, char **argv)                                             
#else                                                                           
int mysqld_main(int argc, char **argv)                                          
#endif                                                                          
{                                                                               
  /*                                                                            
    Perform basic thread library and malloc initialization,                     
    to be able to read defaults files and parse options.                        
  */                                                                            
  my_progname= argv[0];                                                         
                                                                                
#ifndef _WIN32                                                                  
#ifdef WITH_PERFSCHEMA_STORAGE_ENGINE                                           
  pre_initialize_performance_schema();                                          
#endif /*WITH_PERFSCHEMA_STORAGE_ENGINE */                                      
  // For windows, my_init() is called from the win specific mysqld_main         
  if (my_init())                 // init my_sys library & pthreads              
  {                                                                             
    sql_print_error("my_init() failed.");                                       
    flush_error_log_messages();                                                 
    return 1;                                                                   
  }                                                                             
#endif /* _WIN32 */

  orig_argc= argc;                                                              
  orig_argv= argv;                                                              
  my_getopt_use_args_separator= TRUE;                                           
  if (load_defaults(MYSQL_CONFIG_NAME, load_default_groups, &argc, &argv))      
  {                                                                             
    flush_error_log_messages();                                                 
    return 1;                                                                   
  }                                                                             
  my_getopt_use_args_separator= FALSE;                                          
  defaults_argc= argc;                                                          
  defaults_argv= argv;                                                          
  remaining_argc= argc;                                                         
  remaining_argv= argv;                                                         
                                                                                
  /* Must be initialized early for comparison of options name */                
  system_charset_info= &my_charset_utf8_general_ci;                             
                                                                                
  /* Write mysys error messages to the error log. */                            
  local_message_hook= error_log_print;                                          
                                                                                
  int ho_error;                                                                 
                                                                                
#ifdef WITH_PERFSCHEMA_STORAGE_ENGINE                                           
  /*                                                                            
    Initialize the array of performance schema instrument configurations.       
  */                                                                            
  init_pfs_instrument_array();                                                  
#endif /* WITH_PERFSCHEMA_STORAGE_ENGINE */

  ho_error= handle_early_options();                                             
                                                                                
#if !defined(_WIN32) && !defined(EMBEDDED_LIBRARY)                              
                                                                                
  if (opt_bootstrap && opt_daemonize)                                           
  {                                                                             
    fprintf(stderr, "Bootstrap and daemon options are incompatible.\n");        
    exit(MYSQLD_ABORT_EXIT);                                                    
  }                                                                             
                                                                                
  if (opt_daemonize && (isatty(STDOUT_FILENO) || isatty(STDERR_FILENO)))        
  {                                                                             
    fprintf(stderr, "Please set appopriate redirections for "                   
                    "standard output and/or standard error in daemon mode.\n"); 
    exit(MYSQLD_ABORT_EXIT);                                                    
  }                                                                             
                                                                                
  if (opt_daemonize)                                                            
  {                                                                             
    if (chdir("/") < 0)                                                         
    {                                                                           
      fprintf(stderr, "Cannot change to root director: %s\n",                   
                      strerror(errno));                                         
      exit(MYSQLD_ABORT_EXIT);                                                  
    }                                                                           
                                                                                
    if ((pipe_write_fd= mysqld::runtime::mysqld_daemonize()) < 0)               
    {                                                                           
      fprintf(stderr, "mysqld_daemonize failed \n");                            
      exit(MYSQLD_ABORT_EXIT);                                                  
    }                                                                           
  }                                                                             
#endif                                                                          
                                                                                
  init_sql_statement_names();                                                   
  sys_var_init();                                                               
  ulong requested_open_files;                                                   
  adjust_related_options(&requested_open_files);

#ifdef WITH_PERFSCHEMA_STORAGE_ENGINE                                           
  if (ho_error == 0)                                                            
  {                                                                             
    if (!opt_help && !opt_bootstrap)                                            
    {                                                                           
      /* Add sizing hints from the server sizing parameters. */                 
      pfs_param.m_hints.m_table_definition_cache= table_def_size;               
      pfs_param.m_hints.m_table_open_cache= table_cache_size;                   
      pfs_param.m_hints.m_max_connections= max_connections;                     
      pfs_param.m_hints.m_open_files_limit= requested_open_files;               
      pfs_param.m_hints.m_max_prepared_stmt_count= max_prepared_stmt_count;     
                                                                                
      PSI_hook= initialize_performance_schema(&pfs_param);                      
      if (PSI_hook == NULL && pfs_param.m_enabled)                              
      {                                                                         
        pfs_param.m_enabled= false;                                             
        sql_print_warning("Performance schema disabled (reason: init failed).");
      }                                                                         
    }                                                                           
  }                                                                             
#else                                                                           
  /*                                                                            
    Other provider of the instrumentation interface should                      
    initialize PSI_hook here:                                                   
    - HAVE_PSI_INTERFACE is for the instrumentation interface                   
    - WITH_PERFSCHEMA_STORAGE_ENGINE is for one implementation                  
      of the interface,                                                         
    but there could be alternate implementations, which is why                  
    these two defines are kept separate.                                        
  */                                                                            
#endif /* WITH_PERFSCHEMA_STORAGE_ENGINE */

#ifdef HAVE_PSI_INTERFACE                                                       
  /*                                                                            
    Obtain the current performance schema instrumentation interface,            
    if available.                                                               
  */                                                                            
  if (PSI_hook)                                                                 
  {                                                                             
    PSI *psi_server= (PSI*) PSI_hook->get_interface(PSI_CURRENT_VERSION);       
    if (likely(psi_server != NULL))                                             
    {                                                                           
      set_psi_server(psi_server);                                               
                                                                                
      /*                                                                        
        Now that we have parsed the command line arguments, and have initialized
        the performance schema itself, the next step is to register all the     
        server instruments.                                                     
      */                                                                        
      init_server_psi_keys();                                                   
      /* Instrument the main thread */                                          
      PSI_thread *psi= PSI_THREAD_CALL(new_thread)(key_thread_main, NULL, 0);   
      PSI_THREAD_CALL(set_thread_os_id)(psi);                                   
      PSI_THREAD_CALL(set_thread)(psi);                                         
                                                                                
      /*                                                                        
        Now that some instrumentation is in place,                              
        recreate objects which were initialised early,                          
        so that they are instrumented as well.                                  
      */                                                                        
      my_thread_global_reinit();                                                
    }                                                                           
  }                                                                             
#endif /* HAVE_PSI_INTERFACE */

  init_error_log();                                                             
                                                                                
  /* Initialize audit interface globals. Audit plugins are inited later. */     
  mysql_audit_initialize();                                                     
                                                                                
#ifndef EMBEDDED_LIBRARY                                                        
  Srv_session::module_init();                                                   
#endif                                                                          
                                                                                
  /*                                                                            
    Perform basic query log initialization. Should be called after              
    MY_INIT, as it initializes mutexes.                                         
  */                                                                            
  query_logger.init();                                                          
                                                                                
  if (ho_error)                                                                 
  {                                                                             
    /*                                                                          
      Parsing command line option failed,                                       
      Since we don't have a workable remaining_argc/remaining_argv              
      to continue the server initialization, this is as far as this             
      code can go.                                                              
      This is the best effort to log meaningful messages:                       
      - messages will be printed to stderr, which is not redirected yet,        
      - messages will be printed in the NT event log, for windows.              
    */                                                                          
    flush_error_log_messages();                                                 
    /*                                                                          
      Not enough initializations for unireg_abort()                             
      Using exit() for windows.                                                 
    */                                                                          
    exit (MYSQLD_ABORT_EXIT);                                                   
  }                                                                             
                                                                                
  if (init_common_variables())                                                  
    unireg_abort(MYSQLD_ABORT_EXIT);        // Will do exit                     
                                                                                
  my_init_signals();                                                            
                                                                                
  size_t guardize= 0;                                                           
#ifndef _WIN32                                                                  
  int retval= pthread_attr_getguardsize(&connection_attrib, &guardize);         
  DBUG_ASSERT(retval == 0);                                                     
  if (retval != 0)                                                              
    guardize= my_thread_stack_size;                                             
#endif                                                                          
                                                                                
#if defined(__ia64__) || defined(__ia64)                                        
  /*                                                                            
    Peculiar things with ia64 platforms - it seems we only have half the        
    stack size in reality, so we have to double it here                         
  */                                                                            
  guardize= my_thread_stack_size;                                               
#endif

  my_thread_attr_setstacksize(&connection_attrib,                               
                            my_thread_stack_size + guardize);                   
                                                                                
  {                                                                             
    /* Retrieve used stack size;  Needed for checking stack overflows */        
    size_t stack_size= 0;                                                       
    my_thread_attr_getstacksize(&connection_attrib, &stack_size);               
                                                                                
    /* We must check if stack_size = 0 as Solaris 2.9 can return 0 here */      
    if (stack_size && stack_size < (my_thread_stack_size + guardize))           
    {                                                                           
      sql_print_warning("Asked for %lu thread stack, but got %ld",              
                        my_thread_stack_size + guardize, (long) stack_size);    
#if defined(__ia64__) || defined(__ia64)                                        
      my_thread_stack_size= stack_size / 2;                                     
#else                                                                           
      my_thread_stack_size= static_cast<ulong>(stack_size - guardize);          
#endif                                                                          
    }                                                                           
  }                                                                             
                                                                                
#ifndef DBUG_OFF                                                                
  test_lc_time_sz();                                                            
  srand(static_cast<uint>(time(NULL)));                                         
#endif                                                                          
                                                                                
  /*                                                                            
    We have enough space for fiddling with the argv, continue                   
  */                                                                            
  if (my_setwd(mysql_real_data_home,MYF(MY_WME)) && !opt_help)                  
  {                                                                             
    sql_print_error("failed to set datadir to %s", mysql_real_data_home);       
    unireg_abort(MYSQLD_ABORT_EXIT);        /* purecov: inspected */            
  }

#ifndef _WIN32                                                                  
  if ((user_info= check_user(mysqld_user)))                                     
  {                                                                             
#if HAVE_CHOWN                                                                  
    if (unlikely(opt_initialize))                                               
    {                                                                           
      /* need to change the owner of the freshly created data directory */      
      MY_STAT stat;                                                             
      char errbuf[MYSYS_STRERROR_SIZE];                                         
      bool must_chown= true;                                                    
                                                                                
      /* fetch the directory's owner */                                         
      if (!my_stat(mysql_real_data_home, &stat, MYF(0)))                        
      {                                                                         
        sql_print_information("Can't read data directory's stats (%d): %s."     
                              "Assuming that it's not owned by the same user/group",
                              my_errno(),                                       
                              my_strerror(errbuf, sizeof(errbuf), my_errno())); 
      }                                                                         
      /* Don't change it if it's already the same as SElinux stops this */      
      else if(stat.st_uid == user_info->pw_uid &&                               
              stat.st_gid == user_info->pw_gid)                                 
        must_chown= false;                                                      
                                                                                
      if (must_chown &&                                                         
          chown(mysql_real_data_home, user_info->pw_uid, user_info->pw_gid)     
         )                                                                      
      {                                                                         
        sql_print_error("Can't change data directory owner to %s", mysqld_user);
        unireg_abort(1);                                                        
      }                                                                         
    }                                                                           
#endif                                                                          
                                                                                
                                                                                
#if defined(HAVE_MLOCKALL) && defined(MCL_CURRENT)                              
    if (locked_in_memory) // getuid() == 0 here                                 
      set_effective_user(user_info);                                            
    else                                                                        
#endif                                                                          
      set_user(mysqld_user, user_info);                                         
  }                                                                             
#endif // !_WIN32

  //If the binlog is enabled, one needs to provide a server-id                  
  if (opt_bin_log && !(server_id_supplied) )                                    
  {                                                                             
    sql_print_error("You have enabled the binary log, but you haven't provided "
                    "the mandatory server-id. Please refer to the proper "      
                    "server start-up parameters documentation");                
    unireg_abort(MYSQLD_ABORT_EXIT);                                            
  }                                                                             
                                                                                
  /*                                                                            
   The subsequent calls may take a long time : e.g. innodb log read.            
   Thus set the long running service control manager timeout                    
  */                                                                            
#if defined(_WIN32)                                                             
  Service.SetSlowStarting(slow_start_timeout);                                  
#endif                                                                          
                                                                                
  if (init_server_components())                                                 
    unireg_abort(MYSQLD_ABORT_EXIT);                                            
                                                                                
  if (mysql_audit_notify(MYSQL_AUDIT_SERVER_STARTUP_STARTUP,                    
                         (const char**)argv, argc))                             
    unireg_abort(MYSQLD_ABORT_EXIT);                                            
                                                                                
  /*                                                                            
    Each server should have one UUID. We will create it automatically, if it    
    does not exist.                                                             
   */                                                                           
  if (init_server_auto_options())                                               
  {                                                                             
    sql_print_error("Initialization of the server's UUID failed because it could"
                    " not be read from the auto.cnf file. If this is a new"     
                    " server, the initialization failed because it was not"     
                    " possible to generate a new UUID.");                       
    unireg_abort(MYSQLD_ABORT_EXIT);                                            
  }                                                                             
                                                                                
  /*                                                                            
    Add server_uuid to the sid_map.  This must be done after                    
    server_uuid has been initialized in init_server_auto_options and            
    after the binary log (and sid_map file) has been initialized in             
    init_server_components().                                                   
                                                                                
    No error message is needed: init_sid_map() prints a message.                
                                                                                
    Strictly speaking, this is not currently needed when                        
    opt_bin_log==0, since the variables that gtid_state->init                   
    initializes are not currently used in that case.  But we call it            
    regardless to avoid possible future bugs if gtid_state ever                 
    needs to do anything else.                                                  
  */                                                                            
  global_sid_lock->rdlock();                                                    
  int gtid_ret= gtid_state->init();                                             
  global_sid_lock->unlock();

  if (gtid_ret)                                                                 
    unireg_abort(MYSQLD_ABORT_EXIT);                                            
                                                                                
  // Initialize executed_gtids from mysql.gtid_executed table.                  
  if (gtid_state->read_gtid_executed_from_table() == -1)                        
    unireg_abort(1);                                                            
                                                                                
  if (opt_bin_log)
  { ... }

  if (init_ssl())                                                               
    unireg_abort(MYSQLD_ABORT_EXIT);                                            
  if (network_init())                                                           
    unireg_abort(MYSQLD_ABORT_EXIT);                                            
                                                                                
#ifdef _WIN32                                                                   
#ifndef EMBEDDED_LIBRARY                                                        
  if (opt_require_secure_transport &&                                           
      !opt_enable_shared_memory && !opt_use_ssl &&                              
      !opt_initialize && !opt_bootstrap)                                        
  {                                                                             
    sql_print_error("Server is started with --require-secure-transport=ON "     
                    "but no secure transports (SSL or Shared Memory) are "      
                    "configured.");                                             
    unireg_abort(MYSQLD_ABORT_EXIT);                                            
  }                                                                             
#endif

#endif                                                                          
                                                                                
  /*                                                                            
   Initialize my_str_malloc(), my_str_realloc() and my_str_free()               
  */                                                                            
  my_str_malloc= &my_str_malloc_mysqld;                                         
  my_str_free= &my_str_free_mysqld;                                             
  my_str_realloc= &my_str_realloc_mysqld;                                       
                                                                                
  error_handler_hook= my_message_sql;                                           
                                                                                
  /* Save pid of this process in a file */                                      
  if (!opt_bootstrap)                                                           
    create_pid_file();                                                          
                                                                                
                                                                                
  /* Read the optimizer cost model configuration tables */                      
  if (!opt_bootstrap)                                                           
    reload_optimizer_cost_constants();                                          
                                                                                
  if (mysql_rm_tmp_tables() || acl_init(opt_noacl) ||                           
      my_tz_init((THD *)0, default_tz_name, opt_bootstrap) ||                   
      grant_init(opt_noacl))                                                    
  {                                                                             
    abort_loop= true;                                                           
                                                                                
    delete_pid_file(MYF(MY_WME));                                               
                                                                                
    unireg_abort(MYSQLD_ABORT_EXIT);                                            
  }                                                                             
                                                                                
  if (!opt_bootstrap)                                                           
    servers_init(0);                                                            
                                                                                
  if (!opt_noacl)                                                               
  {                                                                             
#ifdef HAVE_DLOPEN                                                              
    udf_init();                                                                 
#endif                                                                          
  }
  init_status_vars();                                                           
  /* If running with bootstrap, do not start replication. */                    
  if (opt_bootstrap)                                                            
    opt_skip_slave_start= 1;                                                    
                                                                                
  check_binlog_cache_size(NULL);                                                
  check_binlog_stmt_cache_size(NULL);                                           
                                                                                
  binlog_unsafe_map_init();                                                     
                                                                                
  /* If running with bootstrap, do not start replication. */                    
  if (!opt_bootstrap)                                                           
  {                                                                             
    // Make @@slave_skip_errors show the nice human-readable value.             
    set_slave_skip_errors(&opt_slave_skip_errors);                              
                                                                                
    /*                                                                          
      init_slave() must be called after the thread keys are created.            
    */                                                                          
    if (server_id != 0)                                                         
      init_slave(); /* Ignoring errors while configuring replication. */        
  }                                                                             
                                                                                
#ifdef WITH_PERFSCHEMA_STORAGE_ENGINE                                           
  initialize_performance_schema_acl(opt_bootstrap);                             
  /*                                                                            
    Do not check the structure of the performance schema tables                 
    during bootstrap:                                                           
    - the tables are not supposed to exist yet, bootstrap will create them      
    - a check would print spurious error messages                               
  */                                                                            
  if (! opt_bootstrap)                                                          
    check_performance_schema();                                                 
#endif                                                                          
                                                                                
  initialize_information_schema_acl();                                          
                                                                                
  execute_ddl_log_recovery();                                                   
  (void) RUN_HOOK(server_state, after_recovery, (NULL));                        
                                                                                
  if (Events::init(opt_noacl || opt_bootstrap))                                 
    unireg_abort(MYSQLD_ABORT_EXIT);                                            
                                                                                
#ifndef _WIN32                                                                  
  //  Start signal handler thread.                                              
  start_signal_handler();                                                       
#endif

  if (opt_bootstrap)                                                            
  {                                                                             
    start_processing_signals();                                                 
                                                                                
    int error= bootstrap(mysql_stdin);                                          
    unireg_abort(error ? MYSQLD_ABORT_EXIT : MYSQLD_SUCCESS_EXIT);              
  }                                                                             
  if (opt_init_file && *opt_init_file)                                          
  {                                                                             
    if (read_init_file(opt_init_file))                                          
      unireg_abort(MYSQLD_ABORT_EXIT);                                          
  }                                                                             
                                                                                
#ifdef _WIN32                                                                   
  create_shutdown_thread();                                                     
#endif                                                                          
  start_handle_manager();                                                       
                                                                                
  create_compress_gtid_table_thread();                                          
                                                                                
  sql_print_information(ER_DEFAULT(ER_STARTUP),                                 
                        my_progname,                                            
                        server_version,                                         
#ifdef HAVE_SYS_UN_H                                                            
                        (opt_bootstrap ? (char*) "" : mysqld_unix_port),        
#else                                                                           
                        (char*) "",                                             
#endif                                                                          
                         mysqld_port,                                           
                         MYSQL_COMPILATION_COMMENT);                            
#if defined(_WIN32)                                                             
  Service.SetRunning();                                                         
#endif                                                                          
                                                                                
  start_processing_signals();                                                   
                                                                                
#ifdef WITH_NDBCLUSTER_STORAGE_ENGINE                                           
  /* engine specific hook, to be made generic */                                
  if (ndb_wait_setup_func && ndb_wait_setup_func(opt_ndb_wait_setup))           
  {                                                                             
    sql_print_warning("NDB : Tables not available after %lu seconds."           
                      "  Consider increasing --ndb-wait-setup value",           
                      opt_ndb_wait_setup);                                      
  }                                                                             
#endif                                                                          
  (void) RUN_HOOK(server_state, before_handle_connection, (NULL));              
                                                                                
  DBUG_PRINT("info", ("Block, listening for incoming connections"));            
                                                                                
  (void)MYSQL_SET_STAGE(0 ,__FILE__, __LINE__);                                 
                                                                                
  server_operational_state= SERVER_OPERATING;
#if defined(_WIN32)                                                             
  setup_conn_event_handler_threads();                                           
#else                                                                           
  mysql_mutex_lock(&LOCK_socket_listener_active);                               
  // Make it possible for the signal handler to kill the listener.              
  socket_listener_active= true;                                                 
  mysql_mutex_unlock(&LOCK_socket_listener_active);                             
                                                                                
  if (opt_daemonize)                                                            
    mysqld::runtime::signal_parent(pipe_write_fd,1);                            
                                                                                
  mysqld_socket_acceptor->connection_event_loop();                              
#endif /* _WIN32 */                                                             
  server_operational_state= SERVER_SHUTTING_DOWN;                               
                                                                                
  DBUG_PRINT("info", ("No longer listening for incoming connections"));         
                                                                                
  mysql_audit_notify(MYSQL_AUDIT_SERVER_SHUTDOWN_SHUTDOWN,                      
                     MYSQL_AUDIT_SERVER_SHUTDOWN_REASON_SHUTDOWN,               
                     MYSQLD_SUCCESS_EXIT);                                      
                                                                                
  terminate_compress_gtid_table_thread();                                       
  /*                                                                            
    Save set of GTIDs of the last binlog into gtid_executed table               
    on server shutdown.                                                         
  */                                                                            
  if (opt_bin_log)                                                              
    if (gtid_state->save_gtids_of_last_binlog_into_table(false))                
      sql_print_warning("Failed to save the set of Global Transaction "         
                        "Identifiers of the last binary log into the "          
                        "mysql.gtid_executed table while the server was "       
                        "shutting down. The next server restart will make "     
                        "another attempt to save Global Transaction "           
                        "Identifiers into the table.");                         
                                                                                
#ifndef _WIN32                                                                  
  mysql_mutex_lock(&LOCK_socket_listener_active);                               
  // Notify the signal handler that we have stopped listening for connections.  
  socket_listener_active= false;                                                
  mysql_cond_broadcast(&COND_socket_listener_active);                           
  mysql_mutex_unlock(&LOCK_socket_listener_active);                             
#endif // !_WIN32                                                               
                                                                                
#ifdef HAVE_PSI_THREAD_INTERFACE                                                
  /*                                                                            
    Disable the main thread instrumentation,                                    
    to avoid recording events during the shutdown.                              
  */                                                                            
  PSI_THREAD_CALL(delete_current_thread)();                                     
#endif                                                                          
                                                                                
  DBUG_PRINT("info", ("Waiting for shutdown proceed"));                         
  int ret= 0;                                                                   
#ifdef _WIN32                                                                   
  if (shutdown_thr_handle.handle)
    ret= my_thread_join(&shutdown_thr_handle, NULL);                            
  shutdown_thr_handle.handle= NULL;                                             
  if (0 != ret)                                                                 
    sql_print_warning("Could not join shutdown thread. error:%d", ret);         
#else                                                                           
  if (signal_thread_id.thread != 0)                                             
    ret= my_thread_join(&signal_thread_id, NULL);                               
  signal_thread_id.thread= 0;                                                   
  if (0 != ret)                                                                 
    sql_print_warning("Could not join signal_thread. error:%d", ret);           
#endif                                                                          
                                                                                
  clean_up(1);                                                                  
  mysqld_exit(MYSQLD_SUCCESS_EXIT);                                             
}
```

## InnoDB

### InnoDB Source Code Distribution

`mysql-5.7.11/storage/innobase`

#### CMakeLists.txt

```cmake
# Copyright (c) 2006, 2015, Oracle and/or its affiliates. All rights reserved.
#
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; version 2 of the License.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program; if not, write to the Free Software
# Foundation, Inc., 51 Franklin St, Fifth Floor, Boston, MA  02110-1301 USA

# This is the CMakeLists for InnoDB

INCLUDE(innodb.cmake)

SET(INNOBASE_SOURCES
    api/api0api.cc
    api/api0misc.cc
    btr/btr0btr.cc
    btr/btr0cur.cc
    btr/btr0pcur.cc
    btr/btr0sea.cc
    btr/btr0bulk.cc
    buf/buf0buddy.cc
    buf/buf0buf.cc
    buf/buf0dblwr.cc
    buf/buf0checksum.cc
    buf/buf0dump.cc
    buf/buf0flu.cc
    buf/buf0lru.cc
    buf/buf0rea.cc
    data/data0data.cc
    data/data0type.cc
    dict/dict0boot.cc
    dict/dict0crea.cc
    dict/dict0dict.cc
    dict/dict0load.cc
    dict/dict0mem.cc
    dict/dict0stats.cc
    dict/dict0stats_bg.cc
    eval/eval0eval.cc
    eval/eval0proc.cc
    fil/fil0fil.cc
    fsp/fsp0fsp.cc
    fsp/fsp0file.cc
    fsp/fsp0space.cc
    fsp/fsp0sysspace.cc
    fut/fut0fut.cc
    fut/fut0lst.cc
    ha/ha0ha.cc
    ha/ha0storage.cc
    ha/hash0hash.cc
    fts/fts0fts.cc
    fts/fts0ast.cc
    fts/fts0blex.cc
    fts/fts0config.cc
    fts/fts0opt.cc
    fts/fts0pars.cc
    fts/fts0que.cc
    fts/fts0sql.cc
    fts/fts0tlex.cc
    gis/gis0geo.cc
    gis/gis0rtree.cc
    gis/gis0sea.cc
    fts/fts0plugin.cc
    handler/ha_innodb.cc
    handler/ha_innopart.cc
    handler/handler0alter.cc
    handler/i_s.cc
    ibuf/ibuf0ibuf.cc
    lock/lock0iter.cc
    lock/lock0prdt.cc
    lock/lock0lock.cc
    lock/lock0wait.cc
    log/log0log.cc
    log/log0recv.cc
    mach/mach0data.cc
    mem/mem0mem.cc
    mtr/mtr0log.cc
    mtr/mtr0mtr.cc
    os/os0file.cc
    os/os0proc.cc
    os/os0event.cc
    os/os0thread.cc
    page/page0cur.cc
    page/page0page.cc
    page/page0zip.cc
    pars/lexyy.cc
    pars/pars0grm.cc
    pars/pars0opt.cc
    pars/pars0pars.cc
    pars/pars0sym.cc
    que/que0que.cc
    read/read0read.cc
    rem/rem0cmp.cc
    rem/rem0rec.cc
    row/row0ext.cc
    row/row0ftsort.cc
    row/row0import.cc
    row/row0ins.cc
    row/row0merge.cc
    row/row0mysql.cc
    row/row0log.cc
    row/row0purge.cc
    row/row0row.cc
    row/row0sel.cc
    row/row0trunc.cc
    row/row0uins.cc
    row/row0umod.cc
    row/row0undo.cc
    row/row0upd.cc
    row/row0quiesce.cc
    row/row0vers.cc
    srv/srv0conc.cc
    srv/srv0mon.cc
    srv/srv0srv.cc
    srv/srv0start.cc
    sync/sync0arr.cc
    sync/sync0rw.cc
    sync/sync0debug.cc
    sync/sync0sync.cc
    trx/trx0i_s.cc
    trx/trx0purge.cc
    trx/trx0rec.cc
    trx/trx0roll.cc
    trx/trx0rseg.cc
    trx/trx0sys.cc
    trx/trx0trx.cc
    trx/trx0undo.cc
    usr/usr0sess.cc
    ut/ut0byte.cc
    ut/ut0crc32.cc
    ut/ut0dbg.cc
    ut/ut0list.cc
    ut/ut0mem.cc
    ut/ut0new.cc
    ut/ut0rbt.cc
    ut/ut0rnd.cc
    ut/ut0ut.cc
    ut/ut0vec.cc
    ut/ut0wqueue.cc)

IF(WITH_INNODB)
  # Legacy option
  SET(WITH_INNOBASE_STORAGE_ENGINE TRUE)
ENDIF()

MYSQL_ADD_PLUGIN(innobase ${INNOBASE_SOURCES} STORAGE_ENGINE
  MANDATORY
  MODULE_OUTPUT_NAME ha_innodb
  LINK_LIBRARIES ${ZLIB_LIBRARY} ${LZ4_LIBRARY})

IF(WITH_INNOBASE_STORAGE_ENGINE)
  ADD_DEPENDENCIES(innobase GenError)
ENDIF()

# Avoid generating Hardware Capabilities due to crc32 instructions
IF(CMAKE_SYSTEM_NAME MATCHES "SunOS" AND CMAKE_SYSTEM_PROCESSOR MATCHES "i386")
  INCLUDE(${MYSQL_CMAKE_SCRIPT_DIR}/compile_flags.cmake)
  MY_CHECK_CXX_COMPILER_FLAG("-Wa,-nH" HAVE_WA_NH)
  IF(HAVE_WA_NH)
    ADD_COMPILE_FLAGS(
      ut/ut0crc32.cc
      COMPILE_FLAGS "-Wa,-nH"
    )
  ENDIF()
ENDIF()

# A GCC bug causes crash when compiling these files on ARM64 with -O1+
# Compile them with -O0 as a workaround until the GCC bug is fixed.
IF(CMAKE_COMPILER_IS_GNUCXX AND CMAKE_SYSTEM_PROCESSOR MATCHES "aarch64")
  INCLUDE(${MYSQL_CMAKE_SCRIPT_DIR}/compile_flags.cmake)
  ADD_COMPILE_FLAGS(
    btr/btr0btr.cc
    btr/btr0cur.cc
    buf/buf0buf.cc
    gis/gis0sea.cc
    COMPILE_FLAGS "-O0"
  )
ENDIF()
```

#### sub-dirs

* `/ha`: HASHING
* `/btr`: B-TREE
* `/buf`: BUFFERING
* `/data`: DATA
* `/dict`: DICTIONARY
* `/eval`: EVALUATING
* `/fil`: The tablespace memory cache
* `/fsp`: File space
* `/fut`: File-based utilities
* `/ibuf`: Insert buffer
* `/log`: LOGGING
* `/mach`: Utilities for converting data from the database file to the machine format
* `/mem`: The memory management
* `/mtr`: MINI-TRANSACTION
* `/os`: OS
* `/page`: PAGE
* `/pars`: PARSING
* `/que`: QUERY GRAPH
* `/read`: READ
* `/rem`: RECORD MANAGER
* `/row`: ROW
* `/srv`: Server
* `/sync`: SYNCHRONIZATION
* `/trx`: Transaction
* `/usr`: Session
* `/ut`: UTILITIES

#### innodb.cmake

```cmake
# Copyright (c) 2006, 2015, Oracle and/or its affiliates. All rights reserved.
#
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; version 2 of the License.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program; if not, write to the Free Software
# Foundation, Inc., 51 Franklin St, Fifth Floor, Boston, MA  02110-1301 USA

# This is the CMakeLists for InnoDB

INCLUDE(CheckFunctionExists)
INCLUDE(CheckCSourceCompiles)
INCLUDE(CheckCSourceRuns)

IF(LZ4_INCLUDE_DIR AND LZ4_LIBRARY)
  ADD_DEFINITIONS(-DHAVE_LZ4=1)
  INCLUDE_DIRECTORIES(${LZ4_INCLUDE_DIR})
ENDIF()

# OS tests
IF(UNIX)
  IF(CMAKE_SYSTEM_NAME STREQUAL "Linux")

    ADD_DEFINITIONS("-DUNIV_LINUX -D_GNU_SOURCE=1")

    CHECK_INCLUDE_FILES (libaio.h HAVE_LIBAIO_H)
    CHECK_LIBRARY_EXISTS(aio io_queue_init "" HAVE_LIBAIO)

    IF(HAVE_LIBAIO_H AND HAVE_LIBAIO)
      ADD_DEFINITIONS(-DLINUX_NATIVE_AIO=1)
      LINK_LIBRARIES(aio)
    ENDIF()

    IF(HAVE_LIBNUMA)
      LINK_LIBRARIES(numa)
    ENDIF()

  ELSEIF(CMAKE_SYSTEM_NAME STREQUAL "SunOS")
    ADD_DEFINITIONS("-DUNIV_SOLARIS")
  ENDIF()
ENDIF()

OPTION(INNODB_COMPILER_HINTS "Compile InnoDB with compiler hints" ON)
MARK_AS_ADVANCED(INNODB_COMPILER_HINTS)

IF(INNODB_COMPILER_HINTS)
   ADD_DEFINITIONS("-DCOMPILER_HINTS")
ENDIF()

SET(MUTEXTYPE "event" CACHE STRING "Mutex type: event, sys or futex")

IF(CMAKE_CXX_COMPILER_ID MATCHES "GNU")
# After: WL#5825 Using C++ Standard Library with MySQL code
#       we no longer use -fno-exceptions
#   SET(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -fno-exceptions")

# Add -Wconversion if compiling with GCC
## As of Mar 15 2011 this flag causes 3573+ warnings. If you are reading this
## please fix them and enable the following code:
#SET(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -Wconversion")

  IF (CMAKE_SYSTEM_PROCESSOR MATCHES "x86_64" OR
      CMAKE_SYSTEM_PROCESSOR MATCHES "i386")
    INCLUDE(CheckCXXCompilerFlag)
    CHECK_CXX_COMPILER_FLAG("-fno-builtin-memcmp" HAVE_NO_BUILTIN_MEMCMP)
    IF (HAVE_NO_BUILTIN_MEMCMP)
      # Work around http://gcc.gnu.org/bugzilla/show_bug.cgi?id=43052
      SET_SOURCE_FILES_PROPERTIES(${CMAKE_CURRENT_SOURCE_DIR}/rem/rem0cmp.cc
    PROPERTIES COMPILE_FLAGS -fno-builtin-memcmp)
    ENDIF()
  ENDIF()
ENDIF()

# Enable InnoDB's UNIV_DEBUG in debug builds
SET(CMAKE_CXX_FLAGS_DEBUG "${CMAKE_CXX_FLAGS_DEBUG} -DUNIV_DEBUG")

OPTION(WITH_INNODB_EXTRA_DEBUG "Enable extra InnoDB debug checks" OFF)
IF(WITH_INNODB_EXTRA_DEBUG)
  IF(NOT WITH_DEBUG)
    MESSAGE(FATAL_ERROR "WITH_INNODB_EXTRA_DEBUG can be enabled only when WITH_DEBUG is enabled")
  ENDIF()

  SET(EXTRA_DEBUG_FLAGS "")
  SET(EXTRA_DEBUG_FLAGS "${EXTRA_DEBUG_FLAGS} -DUNIV_AHI_DEBUG")
  SET(EXTRA_DEBUG_FLAGS "${EXTRA_DEBUG_FLAGS} -DUNIV_DDL_DEBUG")
  SET(EXTRA_DEBUG_FLAGS "${EXTRA_DEBUG_FLAGS} -DUNIV_DEBUG_FILE_ACCESSES")
  SET(EXTRA_DEBUG_FLAGS "${EXTRA_DEBUG_FLAGS} -DUNIV_ZIP_DEBUG")

  SET(CMAKE_CXX_FLAGS_DEBUG "${CMAKE_CXX_FLAGS_DEBUG} ${EXTRA_DEBUG_FLAGS}")
  SET(CMAKE_C_FLAGS_DEBUG "${CMAKE_C_FLAGS_DEBUG} ${EXTRA_DEBUG_FLAGS}")
ENDIF()

CHECK_FUNCTION_EXISTS(sched_getcpu  HAVE_SCHED_GETCPU)
IF(HAVE_SCHED_GETCPU)
 ADD_DEFINITIONS(-DHAVE_SCHED_GETCPU=1)
ENDIF()

CHECK_FUNCTION_EXISTS(nanosleep HAVE_NANOSLEEP)
IF(HAVE_NANOSLEEP)
 ADD_DEFINITIONS(-DHAVE_NANOSLEEP=1)
ENDIF()

IF(NOT MSVC)
  CHECK_C_SOURCE_RUNS(
  "
  #define _GNU_SOURCE
  #include <fcntl.h>
  #include <linux/falloc.h>
  int main()
  {
    /* Ignore the return value for now. Check if the flags exist.
    The return value is checked  at runtime. */
    fallocate(0, FALLOC_FL_PUNCH_HOLE | FALLOC_FL_KEEP_SIZE, 0, 0);

    return(0);
  }"
  HAVE_FALLOC_PUNCH_HOLE_AND_KEEP_SIZE
  )
ENDIF()

IF(HAVE_FALLOC_PUNCH_HOLE_AND_KEEP_SIZE)
 ADD_DEFINITIONS(-DHAVE_FALLOC_PUNCH_HOLE_AND_KEEP_SIZE=1)
ENDIF()

IF(NOT MSVC)
# either define HAVE_IB_GCC_ATOMIC_BUILTINS or not
IF(NOT CMAKE_CROSSCOMPILING)
  CHECK_C_SOURCE_RUNS(
  "#include<stdint.h>
  int main()
  {
    __sync_synchronize();
    return(0);
  }"
  HAVE_IB_GCC_SYNC_SYNCHRONISE
  )
  CHECK_C_SOURCE_RUNS(
  "#include<stdint.h>
  int main()
  {
    __atomic_thread_fence(__ATOMIC_ACQUIRE);
    __atomic_thread_fence(__ATOMIC_RELEASE);
    return(0);
  }"
  HAVE_IB_GCC_ATOMIC_THREAD_FENCE
  )
  CHECK_C_SOURCE_RUNS(
  "#include<stdint.h>
  int main()
  {
    unsigned char   a = 0;
    unsigned char   b = 0;
    unsigned char   c = 1;

    __atomic_exchange(&a, &b,  &c, __ATOMIC_RELEASE);
    __atomic_compare_exchange(&a, &b, &c, 0,
                  __ATOMIC_RELEASE, __ATOMIC_ACQUIRE);
    return(0);
  }"
  HAVE_IB_GCC_ATOMIC_COMPARE_EXCHANGE
  )
ENDIF()

IF(HAVE_IB_GCC_SYNC_SYNCHRONISE)
 ADD_DEFINITIONS(-DHAVE_IB_GCC_SYNC_SYNCHRONISE=1)
ENDIF()

IF(HAVE_IB_GCC_ATOMIC_THREAD_FENCE)
 ADD_DEFINITIONS(-DHAVE_IB_GCC_ATOMIC_THREAD_FENCE=1)
ENDIF()

IF(HAVE_IB_GCC_ATOMIC_COMPARE_EXCHANGE)
 ADD_DEFINITIONS(-DHAVE_IB_GCC_ATOMIC_COMPARE_EXCHANGE=1)
ENDIF()

 # either define HAVE_IB_ATOMIC_PTHREAD_T_GCC or not
IF(NOT CMAKE_CROSSCOMPILING)
  CHECK_C_SOURCE_RUNS(
  "
  #include <pthread.h>
  #include <string.h>

  int main() {
    pthread_t       x1;
    pthread_t       x2;
    pthread_t       x3;

    memset(&x1, 0x0, sizeof(x1));
    memset(&x2, 0x0, sizeof(x2));
    memset(&x3, 0x0, sizeof(x3));

    __sync_bool_compare_and_swap(&x1, x2, x3);

    return(0);
  }"
  HAVE_IB_ATOMIC_PTHREAD_T_GCC)
ENDIF()
IF(HAVE_IB_ATOMIC_PTHREAD_T_GCC)
  ADD_DEFINITIONS(-DHAVE_IB_ATOMIC_PTHREAD_T_GCC=1)
ENDIF()

# Only use futexes on Linux if GCC atomics are available
IF(NOT MSVC AND NOT CMAKE_CROSSCOMPILING)
  CHECK_C_SOURCE_RUNS(
  "
  #include <stdio.h>
  #include <unistd.h>
  #include <errno.h>
  #include <assert.h>
  #include <linux/futex.h>
  #include <unistd.h>
  #include <sys/syscall.h>

   int futex_wait(int* futex, int v) {
    return(syscall(SYS_futex, futex, FUTEX_WAIT_PRIVATE, v, NULL, NULL, 0));
   }

   int futex_signal(int* futex) {
    return(syscall(SYS_futex, futex, FUTEX_WAKE, 1, NULL, NULL, 0));
   }

  int main() {
    int ret;
    int m = 1;

    /* It is setup to fail and return EWOULDBLOCK. */
    ret = futex_wait(&m, 0);
    assert(ret == -1 && errno == EWOULDBLOCK);
    /* Shouldn't wake up any threads. */
    assert(futex_signal(&m) == 0);

    return(0);
  }"
  HAVE_IB_LINUX_FUTEX)
ENDIF()
IF(HAVE_IB_LINUX_FUTEX)
  ADD_DEFINITIONS(-DHAVE_IB_LINUX_FUTEX=1)
ENDIF()

ENDIF(NOT MSVC)

CHECK_FUNCTION_EXISTS(asprintf  HAVE_ASPRINTF)
CHECK_FUNCTION_EXISTS(vasprintf  HAVE_VASPRINTF)

# Solaris atomics
IF(CMAKE_SYSTEM_NAME STREQUAL "SunOS")
  IF(NOT CMAKE_CROSSCOMPILING)
  CHECK_C_SOURCE_COMPILES(
  "#include <mbarrier.h>
  int main() {
    __machine_r_barrier();
    __machine_w_barrier();
    return(0);
  }"
  HAVE_IB_MACHINE_BARRIER_SOLARIS)
  ENDIF()
  IF(HAVE_IB_MACHINE_BARRIER_SOLARIS)
    ADD_DEFINITIONS(-DHAVE_IB_MACHINE_BARRIER_SOLARIS=1)
  ENDIF()
ENDIF()

IF(MSVC)
  ADD_DEFINITIONS(-DHAVE_WINDOWS_MM_FENCE)
ENDIF()

IF(MUTEXTYPE MATCHES "event")
  ADD_DEFINITIONS(-DMUTEX_EVENT)
ELSEIF(MUTEXTYPE MATCHES "futex" AND DEFINED HAVE_IB_LINUX_FUTEX)
  ADD_DEFINITIONS(-DMUTEX_FUTEX)
ELSE()
   ADD_DEFINITIONS(-DMUTEX_SYS)
ENDIF()

# Include directories under innobase
INCLUDE_DIRECTORIES(${CMAKE_SOURCE_DIR}/storage/innobase/include
            ${CMAKE_SOURCE_DIR}/storage/innobase/handler
                    ${CMAKE_SOURCE_DIR}/libbinlogevents/include )
```

### Physical Record

Name                | Size
--------------------|-------------------------------------------
Field Start Offsets | (F*1) or (F*2) bytes (F: Number of Fields)
Extra Bytes         | 6 bytes
Field Contents      | depends on content

* FIELD START OFFSETS
    * a list of nubers containing the information 'where a field starts'
    * The Field Start Offsets is a list in which each entry is the position, relative to the Origin, of the start of the next field. The entries are in reverse order, that is, the first field's offset is at the end of the list.
    * There are two complications for special cases:
        * Complication #1: The size of each offset can be either one byte or two bytes. One-byte offsets are only usable if the total record size is less than 127. There is a flag in the "Extra Bytes" part which will tell you whether the size is one byte or two bytes.
        * Complication #2: The most significant bits of an offset may contain flag values. The next two paragraphs explain what the contents are.
* EXTRA BYTES
    * a fixed-size header
* FIELD CONTENTS
    * contains the actual data

The "Origin" or "Zero Point" of a record is the first byte of the Field Contents --- not the first byte of the Field Start Offsets. If there is a pointer to a record, that pointer is pointing to the Origin. Therefore the first two parts of the record are addressed by subtracting from the pointer, and only the third part is addressed by adding to the pointer.

## References

* [http://dev.mysql.com/doc/internals/en/](http://dev.mysql.com/doc/internals/en/)
* InnoDB Internals: InnoDB File Formats and Source Code Structure,MySQL Conference, April 2009, Heikki Tuuri CEO Innobase, Calvin Sun Principal Engineer, Oracle Corporation

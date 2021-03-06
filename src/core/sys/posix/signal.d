/**
 * D header file for POSIX.
 *
 * on posix SIGUSR1 and SIGUSR2 are used by the gc, and should not be used/handled/blocked
 *
 * Copyright: Public Domain
 * License:   Public Domain
 * Authors:   Sean Kelly
 * Standards: The Open Group Base Specifications Issue 6, IEEE Std 1003.1, 2004 Edition
 */
module core.sys.posix.signal;

import core.sys.posix.config;
version( solaris ) {
    import core.stdc.stdint;
}
public import core.stdc.signal;
public import core.stdc.stddef;          // for size_t
public import core.sys.posix.sys.types; // for pid_t
//public import core.sys.posix.time;      // for timespec, now defined here

extern (C):

private alias void function(int) sigfn_t;
private alias void function(int, siginfo_t*, void*) sigactfn_t;

//
// Required
//

//SIG_DFL (defined in core.stdc.signal)
//SIG_ERR (defined in core.stdc.signal)
//SIG_IGN (defined in core.stdc.signal)

//sig_atomic_t (defined in core.stdc.signal)

enum
{
    SIGEV_SIGNAL,
    SIGEV_NONE,
    SIGEV_THREAD
}

union sigval
{
    int     sival_int;
    void*   sival_ptr;
}

private extern (C)
{
    int __libc_current_sigrtmin();
    int __libc_current_sigrtmax();
}

int SIGRTMIN() {
    static int sig = -1;
    if (sig == -1) {
        sig = __libc_current_sigrtmin();
    }
    return sig;
}

int SIGRTMAX() {
    static int sig = -1;
    if (sig == -1) {
        sig = __libc_current_sigrtmax();
    }
    return sig;
}

//SIGABRT (defined in core.stdc.signal)
const SIGALRM   = 14;
const SIGBUS    = 7;
const SIGCHLD   = 17;
const SIGCONT   = 18;
//SIGFPE (defined in core.stdc.signal)
const SIGHUP    = 1;
//SIGILL (defined in core.stdc.signal)
//SIGINT (defined in core.stdc.signal)
const SIGKILL   = 9;
const SIGPIPE   = 13;
const SIGQUIT   = 3;
//SIGSEGV (defined in core.stdc.signal)
const SIGSTOP   = 19;
//SIGTERM (defined in core.stdc.signal)
const SIGTSTP   = 20;
const SIGTTIN   = 21;
const SIGTTOU   = 22;
const SIGUSR1   = 10;
const SIGUSR2   = 12;
const SIGURG    = 23;

struct sigaction_t
{
    static if( true /* __USE_POSIX199309 */ )
    {
        union
        {
            sigfn_t     sa_handler;
            sigactfn_t  sa_sigaction;
        }
    }
    else
    {
        sigfn_t     sa_handler;
    }
    version(freebsd){
        int             sa_flags;
        sigset_t        sa_mask;
    }else{
        sigset_t        sa_mask;
        int             sa_flags;
    }

    version( darwin ) {} else {
        void function() sa_restorer;
    }
}

//
// C Extension (CX)
//

const SIG_HOLD = cast(sigfn_t) 1;

private const _SIGSET_NWORDS = 1024 / (8 * c_ulong.sizeof);

struct sigset_t
{
    c_ulong[_SIGSET_NWORDS] __val;
}

// pid_t  (defined in sys.types)

//SIGABRT (defined in core.stdc.signal)
//SIGFPE  (defined in core.stdc.signal)
//SIGILL  (defined in core.stdc.signal)
//SIGINT  (defined in core.stdc.signal)
//SIGSEGV (defined in core.stdc.signal)
//SIGTERM (defined in core.stdc.signal)

const SA_NOCLDSTOP  = 1; // (CX|XSI)

const SIG_BLOCK     = 0;
const SIG_UNBLOCK   = 1;
const SIG_SETMASK   = 2;

private const __SI_MAX_SIZE = 128;

static if( false /* __WORDSIZE == 64 */ )
{
    private const __SI_PAD_SIZE = ((__SI_MAX_SIZE / int.sizeof) - 4);
}
else
{
    private const __SI_PAD_SIZE = ((__SI_MAX_SIZE / int.sizeof) - 3);
}

struct siginfo_t
{
    int si_signo;       // Signal number
    int si_errno;       // If non-zero, an errno value associated with
    // this signal, as defined in <errno.h>
    int si_code;        // Signal code

    union _sifields_t
    {
        int[__SI_PAD_SIZE] _pad;

        // kill()
        struct _kill_t
        {
            pid_t si_pid; // Sending process ID
            uid_t si_uid; // Real user ID of sending process
        } _kill_t _kill;

        // POSIX.1b timers.
        struct _timer_t
        {
            int    si_tid;     // Timer ID
            int    si_overrun; // Overrun count
            sigval si_sigval;  // Signal value
        } _timer_t _timer;

        // POSIX.1b signals
        struct _rt_t
        {
            pid_t  si_pid;    // Sending process ID
            uid_t  si_uid;    // Real user ID of sending process
            sigval si_sigval; // Signal value
        } _rt_t _rt;

        // SIGCHLD
        struct _sigchild_t
        {
            pid_t   si_pid;    // Which child
            uid_t   si_uid;    // Real user ID of sending process
            int     si_status; // Exit value or signal
            clock_t si_utime;
            clock_t si_stime;
        } _sigchild_t _sigchld;

        // SIGILL, SIGFPE, SIGSEGV, SIGBUS
        struct _sigfault_t
        {
            void*     si_addr;  // Faulting insn/memory ref
        } _sigfault_t _sigfault;

        // SIGPOLL
        struct _sigpoll_t
        {
            c_long   si_band;   // Band event for SIGPOLL
            int      si_fd;
        } _sigpoll_t _sigpoll;
    } _sifields_t _sifields;
}

enum
{
    SI_ASYNCNL = -60,
    SI_TKILL   = -6,
    SI_SIGIO,
    SI_ASYNCIO,
    SI_MESGQ,
    SI_TIMER,
    SI_QUEUE,
    SI_USER,
    SI_KERNEL  = 0x80
}

int kill(pid_t, int);
int sigaction(int, in sigaction_t*, sigaction_t*);
int sigaddset(sigset_t*, int);
int sigdelset(sigset_t*, int);
int sigemptyset(sigset_t*);
int sigfillset(sigset_t*);
int sigismember(in sigset_t*, int);
int sigpending(sigset_t*);
int sigprocmask(int, in sigset_t*, sigset_t*);
int sigsuspend(in sigset_t*);
int sigwait(in sigset_t*, int*);

//
// XOpen (XSI)
//
const SIGPOLL       = 29;
const SIGPROF       = 27;
const SIGSYS        = 31;
const SIGTRAP       = 5;
const SIGVTALRM     = 26;
const SIGXCPU       = 24;
const SIGXFSZ       = 25;

const SA_ONSTACK    = 0x08000000;
const SA_RESETHAND  = 0x80000000;
const SA_RESTART    = 0x10000000;
const SA_SIGINFO    = 4;
const SA_NOCLDWAIT  = 2;
const SA_NODEFER    = 0x40000000;
const SS_ONSTACK    = 1;
const SS_DISABLE    = 2;
const MINSIGSTKSZ   = 2048;
const SIGSTKSZ      = 8192;

//ucontext_t (defined in core.stdc.posix.ucontext)
//mcontext_t (defined in core.stdc.posix.ucontext)

struct stack_t
{
    void*   ss_sp;
    int     ss_flags;
    size_t  ss_size;
}

struct sigstack
{
    void*   ss_sp;
    int     ss_onstack;
}

enum
{
    ILL_ILLOPC = 1,
    ILL_ILLOPN,
    ILL_ILLADR,
    ILL_ILLTRP,
    ILL_PRVOPC,
    ILL_PRVREG,
    ILL_COPROC,
    ILL_BADSTK
}

enum
{
    FPE_INTDIV = 1,
    FPE_INTOVF,
    FPE_FLTDIV,
    FPE_FLTOVF,
    FPE_FLTUND,
    FPE_FLTRES,
    FPE_FLTINV,
    FPE_FLTSUB
}

enum
{
    SEGV_MAPERR = 1,
    SEGV_ACCERR
}

enum
{
    BUS_ADRALN = 1,
    BUS_ADRERR,
    BUS_OBJERR
}

enum
{
    TRAP_BRKPT = 1,
    TRAP_TRACE
}

enum
{
    CLD_EXITED = 1,
    CLD_KILLED,
    CLD_DUMPED,
    CLD_TRAPPED,
    CLD_STOPPED,
    CLD_CONTINUED
}

enum
{
    POLL_IN = 1,
    POLL_OUT,
    POLL_MSG,
    POLL_ERR,
    POLL_PRI,
    POLL_HUP
}

sigfn_t bsd_signal(int sig, sigfn_t func);
sigfn_t sigset(int sig, sigfn_t func);

int killpg(pid_t, int);
int sigaltstack(in stack_t*, stack_t*);
int sighold(int);
int sigignore(int);
int siginterrupt(int, int);
int sigpause(int);
int sigrelse(int);

//
// Timer (TMR)
//
/*
NOTE: This should actually be defined in core.stdc.posix.time.
It is defined here instead to break a circular import.

struct timespec
{
time_t  tv_sec;
int     tv_nsec;
}
 */

struct timespec
{
    time_t  tv_sec;
    c_long  tv_nsec;
}

//
// Realtime Signals (RTS)
//

private const __SIGEV_MAX_SIZE = 64;

static if( false /* __WORDSIZE == 64 */ )
{
    private const __SIGEV_PAD_SIZE = ((__SIGEV_MAX_SIZE / int.sizeof) - 4);
}
else
{
    private const __SIGEV_PAD_SIZE = ((__SIGEV_MAX_SIZE / int.sizeof) - 3);
}

struct sigevent
{
    sigval      sigev_value;
    int         sigev_signo;
    int         sigev_notify;

    union _sigev_un_t
    {
        int[__SIGEV_PAD_SIZE] _pad;
        pid_t                 _tid;

        struct _sigev_thread_t
        {
            void function(sigval)   _function;
            void*                   _attribute;
        } _sigev_thread_t _sigev_thread;
    } _sigev_un_t _sigev_un;
}

int sigqueue(pid_t, int, in sigval);
int sigtimedwait(in sigset_t*, siginfo_t*, in timespec*);
int sigwaitinfo(in sigset_t*, siginfo_t*);
//
// Threads (THR)
//
int pthread_kill(pthread_t, int);
int pthread_sigmask(int, in sigset_t*, sigset_t*);

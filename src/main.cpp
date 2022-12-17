#include <stdio.h>
#include <syslog.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <sys/file.h>
#include <errno.h>
#include <sys/types.h>
#include <sys/socket.h>
#include <sys/ioctl.h>
#include <netinet/in.h>
#include <net/if.h>
#include <arpa/inet.h>
#include <unistd.h>
#include <stdio.h>
#include <stdlib.h>
#include <fcntl.h>
#include <signal.h>
#include <sys/wait.h>
#include <iostream>
#include <string.h>
#include <string>
#include <vector>
#include <set>
#include <map>
#include <iostream>
#include <sys/stat.h>
#include <unistd.h>
#include <sys/types.h>
#include <dirent.h>
#include <stdio.h>
#include <iostream>
#include <sys/stat.h>
#include <sys/time.h>

std::vector<std::string> splitpath(const std::string &str, const std::set<char> delimiters)
{
    std::vector<std::string> result;
    char const *pch = str.c_str();
    char const *start = pch;

    for (; *pch; ++pch) {
        if (delimiters.find(*pch) != delimiters.end()) {
            if (start != pch) {
                std::string str(start, pch);
                result.push_back(str);
            } else {
                result.push_back("");
            }

            start = pch + 1;
        }
    }

    result.push_back(start);
    return result;
}

std::vector<pid_t> proc_find(const char *name)
{
    DIR *dir;
    struct dirent *ent;
    char *endptr;
    char buf[512];
    std::vector<pid_t>result;

    if (!(dir = opendir("/proc"))) {
        perror("can't open /proc");
        return std::vector<pid_t>();
    }

    while ((ent = readdir(dir)) != NULL) {
        /* if endptr is not a null character, the directory is not
         * entirely numeric, so ignore it */
        long lpid = strtol(ent->d_name, &endptr, 10);

        if (*endptr != '\0') {
            continue;
        }

        /* try to open the cmdline file */
        snprintf(buf, sizeof(buf), "/proc/%ld/cmdline", lpid);
        FILE *fp = fopen(buf, "r");
//        printf("checking %s\n   ", buf);

        if (fp) {
            if (fgets(buf, sizeof(buf), fp) != NULL) {
                /* check the first token in the file, the program name */
                char *first = strtok(buf, " ");
//                printf("\t  checking %s\n   ", buf);

                if (first) {
                    std::set<char> delims{'/'};
                    std::string processName = splitpath(first, delims).back();

                    if (!strcmp(processName.c_str(), name)) {
                        result.push_back((pid_t)lpid);
                    }
                }
            }

            fclose(fp);
        }
    }

    closedir(dir);
    return result;
}

typedef struct {
    std::string name;
    std::string fullPath;
} process;

const process tools[] = {
    {"hmr-loader", ""},
    {"hmr-ui", ""},
};

const std::string lockFiles[] = {
    "/tmp/.hmr-loader.lock",
    "/tmp/.hmr-ui.lock",
};

int main(int argc, char *argv[])
{
    (void)(argc);
    (void)(argv);

    //tried to kill then in gental way
    for (auto tool : tools) {
        //check if the process is already running
        std::vector<pid_t> pids = proc_find(tool.name.c_str());

        if (pids.size() > 0) {
            printf("process %s is still running, kill it using SIGINT\n", tool.name.c_str());

            for (auto pid : pids) {
                kill(pid, SIGINT);
                printf("\tpid: %d\n", pid);
            }
        }
    }

    //tried to kill them again in brutal way
    for (auto tool : tools) {
        //check if the process is already running
        std::vector<pid_t> pids = proc_find(tool.name.c_str());

        if (pids.size() > 0) {
            printf("process %s is still running, kill it using SIGKIL\n", tool.name.c_str());

            for (auto pid : pids) {
                kill(pid, SIGKILL);
                printf("\tpid: %d\n", pid);
            }
        }
    }

    for (auto file : lockFiles) {
        if (access(file.c_str(), F_OK) != -1) {
            remove(file.c_str());
            printf("remove lock file %s\n", file.c_str());
        }
    }

    printf("clean\n");
    return 0;
}






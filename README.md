## Sample Drake Workfow ##

This project uses [Drake](https://github.com/Factual/drake) and
[Docker](https://docker.com) to fetch data from the
[ICGC Data Portal](https://dcc.icgc.org/repository) and analyzes
gene expression data for clusters. This performs 
[t-Distributed Stochastic Neighbor Embedding
(t-SNE)](http://lvdmaaten.github.io/tsne/) on gene expression data, group by
gender. We don't necessarily see any clustering, but it highlights some of the
features of Drake!

The workflow is represented as:

![graph](http://i.imgur.com/wrFZEJC.png)

*Hint: You can generate the above graph by cloning the repo and running
`./drake --graph`!*

The final output of the workflow is:

![output](http://i.imgur.com/mW3yc2p.png)

## Key Concepts ##

1. **No dependencies**. All you need is Docker.

2. **Integrated analysis environment**. The `drake` script in the home directory
"proxies" commands via Docker. When you run `./drake`, data is generated inside
of Docker, but is accessible on the host file system.

3. **Reproducible results**. Drake provides a consistent pattern for executing a
workflow. Combining this with the isolation of Docker containers, you can ensure
that collaborators get the same results.

How is this achieved?

First, we leverage IPython's [scipystack](http://www.scipy.org/stackspec.html)
image that provides us the base tools we need for our analysis.

Next, we install Drake via our Docker image to create a local image named
`drake`.

Finally, the local executable script `drake` will kick off a container that
executes Drake in the isolated environment. The current working directory is
mounted to `/root` in the container, so any data generated within the workflow
is automatically copied to the current working directory.

This process makes it easy to publish workflows. All you need to do is tell
a collaborator "Clone the repo and run `./drake`." Easy peasy, lemon squeezy!

## Running ##

1. **Install Docker**. If you're on OS X or Windows, this is easily
done with [Docker Toolbox](https://www.docker.com/toolbox) and
[VirtualBox](https://www.virtualbox.org).

2. **Build the image**. Run `docker build -t drake .`. This will take
a few minutes the first time around since Docker has to fetch upstream
images.

3. **Run the workflow**. Run `./drake` and follow the prompts! For additional
information see `./drake --help`.

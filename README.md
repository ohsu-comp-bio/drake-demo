*It's like having a [Galaxy](https://galaxyproject.org/) in the command-line!*

## Sample Drake Workfow ##

This project uses [Drake](https://github.com/Factual/drake) and
[Docker](https://docker.com) to fetch data from the
[ICGC Data Portal](https://dcc.icgc.org/repository) and analyzes
gene expression data for clusters. We use
[t-Distributed Stochastic Neighbor Embedding
(t-SNE)](http://lvdmaaten.github.io/tsne/) on gene expression data, grouping by
gender, to see if there's any inherit structure. We don't necessarily see any
clustering right off the bat, but this workflow highlights some of the
features of Drake.

Take a look at `Drakefile` to see how the workflow is implemented.

The workflow is represented as:

![graph](http://i.imgur.com/wrFZEJC.png)

*Hint: You can generate the above graph by cloning the repo and running
`./drake --graph`!*

The final output of the workflow is:

![output](http://i.imgur.com/mW3yc2p.png)

## Key Concepts ##

1. **No dependencies**. All you need is Docker. You don't even need Drake
   installed on the host.

2. **Integrated analysis environment**. The `drake` script in the home directory
   "proxies" commands via Docker. When you run `./drake`, data is generated
   inside of Docker, but is accessible on the host file system.

3. **Reproducible results**. Drake provides a consistent pattern for executing a
   workflow. Combining this with the isolation of Docker containers, you can
   ensure that collaborators get the same results.

*How is this achieved?*

**We're running Drake inside of Docker.**

First, we leverage IPython's [scipystack](http://www.scipy.org/stackspec.html)
image that provides us the base tools we need for our analysis. Dependencies
are generally managed via the `Dockerfile`.

Next, we install Drake via our Docker image to create a local image named
`drake`.

Finally, the local executable script `drake` will kick off a container that
executes Drake in the isolated environment. The current working directory is
mounted to `/root` in the container, so any data generated within the workflow
is automatically copied to the current working directory.

This process makes it easy to publish workflows. All you need to do is tell
a collaborator "Clone the repo, build the image, and run `./drake`." Easy peasy,
lemon squeezy!

**Why not Bash?**

Bash is pretty ballin'. However, trying to represent workflows within Bash
can be a nightmare, especially for situations of resuming or extending a
workflow. Additionally, ensuring that a workflow works across different
operating systems / environments can be daunting.

**Why not Galaxy?**

Galaxy is also pretty ballin'. However, for some workflows that you want to
iterate over quickly, you may not necessarily have the resources to spin up a
Galaxy server. Also, moving data in and out of Galaxy can be a bottleneck for
those who are wanting to do rapid prototyping. Lastly, bundling and distributing
a Galaxy tool can be difficult, especially trying to share that pipeline with
users who don't have access to Galaxy.

## Running ##

1. **Install Docker**. If you're on OS X or Windows, this is easily done with
   [Docker Toolbox](https://www.docker.com/toolbox) and
   [VirtualBox](https://www.virtualbox.org).

2. **Build the image**. Run `docker build -t drake .`. This will take a few
   minutes the first time around since Docker has to fetch upstream images.

3. **Run the workflow**. Run `./drake` and follow the prompts! For additional
   information see `./drake --help`.

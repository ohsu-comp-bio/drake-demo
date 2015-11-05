*It's like having a [Galaxy](https://galaxyproject.org/) in the command-line!*

# OHSU Data Jamboree Workshop I: Sharing Data Workflows #

## Requirements ##

+ Docker. If on OS X or Windows, make sure to install [Docker Toolbox](https://www.docker.com/toolbox) and [Virtual Box](https://www.virtualbox.org/wiki/Downloads)

## Setting up the environment ##

1. **Configure Docker**. If using Docker Toolbox, create a machine named `drake`. You can do this with:

  `docker-machine create drake --driver virtualbox`
  
  Once you do this, you want to configure your shell environment to use this Docker Machine:
  
  `eval $(docker-machine env drake)`

2. **Fetch the Docker Image**. Get a head start on downloading the Docker image that we're going to use for this workshop:

  `docker pull slnovak/drake-scipystack`
  
3. **Clone the `drake-demo` repository**.

  `git clone https://github.com/ohsu-computational-biology/drake-demo.git`
  
  Note: Windows users might need to change the `./drake` command script to something like:
  
  ```
  docker run -it -v %CD%:/root/workspace slnovak/drake-scipystack drake --base=/root/workspace "%*"
  ```

5. **Test Drake**. Run `./drake --help`

That's it!

## What is Drake? ##

[Drake](https://github.com/Factual/drake) is a tool that is useful for running data processing workflows. Its documentation describes it best:

> Drake is a simple-to-use, extensible, text-based data workflow tool that
> organizes command execution around data and its dependencies. Data processing
> steps are defined along with their inputs and outputs and Drake automatically
> resolves their dependencies and calculates:
> 
>   + which commands to execute (based on file timestamps)
>   + in what order to execute the commands (based on dependencies)
>
> Drake is similar to GNU Make, but designed especially for data workflow
> management. It has HDFS support, allows multiple inputs and outputs, and 
> includes a host of features designed to help you bring sanity to your 
> otherwise chaotic data processing workflows.

### Comparison to other tools ###

There are a number of other tools that are useful for executing workflows.

+ Bash. Ol' trusty. Bash is great for simple scripts, but it does not provide mechanisms for dependency resolution, resuming workflows, etc.

+ [Galaxy](https://galaxyproject.org/). This is used commonly within the bioinformatics community for developing pipelines. However, it does not work well in a terminal environment. Configuring tools / workflows can be somewhat complicated.

+ [Luigi](https://github.com/spotify/luigi). 3.4k stars on Github! Developed by the data scientists at Spotify, this tool seems to be designed for long-running, scheduled jobs. It doesn't seem to scale down to analytical workflows.

#### Where does Drake stand out? ####

I think Drake has a lot of potential for pulling data from multiple data sources, executing various transformations on that data, then analyzing that data. All from the command-line. It should be a baseline for distributing analysis and reports since it contains all of the neccessary steps to recreate it.

## Drake + Docker = ❤️ ##

By combining functionality of both Docker and Drake, you can package up your workflow and its dependencies to execute in an isolated environment. This makes it easy for you to distribute your analysis amongst colleagues and ultimately ensure reproducibility.

## Drakefile Overview ##

Just like in [Make](https://www.gnu.org/software/make/), Drake has a "Drakefile" that defines targets and inputs. Each step is expressed as a block of code that gets executed.

For example:

```
output.txt <- input.txt
  cat $INPUT > $OUTPUT
```

Drake lists outputs on the left side, and inputs on the right side. Drake also supports multiple inputs and outputs:

```
output1.txt, output2.txt <- input1.txt, input2.txt
  cat $INPUT0 > $OUTPUT0
  cat $INPUT1 > $OUTPUT1
```

*Note 0-based indexing!*

The typical process in Drake is to list several steps within a workflow:

```
output1.txt <- input1.txt
  cat $INPUT > $OUTPUT
  
output2.txt <- input2.txt
  cat $INPUT > $OUTPUT
  
output3.txt <- output1.txt, output2.txt
  cat $INPUTS > $OUTPUT
```

We can see here that we're generating two output files and then combining them together to make a third. Drake provides a `--graph` flag that can generate a .png representation of the workflow:

![simple-graph](http://i.imgur.com/lcGFDBh.png)

*Note: Drake will still check for the existence of input files, so make sure to `touch` both `input1.txt` and `input2.txt`*

## Diving into Drake ##

Let's see if Drake is working:

```
› ./drake --help
              -w file-or-dir-name  Name of the workflow file to execute; if a
      --workflow=file-or-dir-name  directory, look for Drakefile there.

                      -j jobs-num  Specifies the number of jobs (commands) to
                  --jobs=jobs-num  run simultaneously. Defaults to 1
                              ...
```

### Example 1: Hello World ###

```
output.txt <-
  echo "Hello World" > $OUTPUT
```

This simple workflow outputs to `output.txt`. Note the following observations:

+ There are no inputs. (Inputs are typically listed to the *right* of the arrow on nthe first line of the step.)

+ We can refer to inputs and outputs via `$INPUT` and `$OUTPUT` in the script. This makes it easy to describe workflow steps without hard-coding in dependencies.

We can run this workflow with:

```
› ./drake -w examples/1-hello-world
The following steps will be run, in order:
  1: /root/workspace/././output.txt <-  [missing output]
Confirm? [y/n]
```

Note how Drake will prompt you before running the workflow to let you know what steps are going to execute. After running the workflow, we can see that `output.txt` has the content we expected:

```
› cat output.txt
Hello World
```

What happens when we try running Drake again?

```
› ./drake -w examples/1-hello-world
The following steps will be run, in order:
  1: /root/workspace/././output.txt <-  [no-input step]
Confirm? [y/n]
```

Drake changed the step state from `[missing output]` to `[no-input step]`, meaning that Drake sees the output file is there, but now classifies it as a step with no inputs and by default will execute it.

Exercise:

1. What happens when you append `[-timecheck]` to the step definition? (Hint: read more about [no-input steps](https://docs.google.com/document/d/1bF-OKNLIG10v_lMes_m4yyaJtAaJKtdK0Jizvi_MNsg/edit#heading=h.26in1rg).)

### Example 2: Merging Files ###

There are many cases where an analysis tool requires multiple inputs. Let's consider a case where we generate some numerical data and want to concatenate the datasets.

```
data1.csv <- [-timecheck python]
  import numpy as np
  data = np.random.random((10, 2))
  np.savetxt("$[OUTPUT]", data, delimiter=",") 

data2.csv <- [-timecheck python]
  import numpy as np
  data = np.random.random((10, 2))
  np.savetxt("$[OUTPUT]", data, delimiter=",") 

combined.csv <- data1.csv, data2.csv
  cat $INPUTS > $OUTPUT
```

You can run this example with:

```
› ./drake -w examples/2-merging-files
The following steps will be run, in order:
  1: /root/workspace/data1.csv <-  [missing output]
  2: /root/workspace/data2.csv <-  [missing output]
  3: /root/workspace/combined.csv <- /root/workspace/data1.csv, /root/workspace/data2.csv [projected timestamped]
Confirm? [y/n]
```

Exercise:

1. What happens if you edit `data1.csv` and change a digit to something else? Try re-running the workflow.

### Example 3: Gene Expression Analysis ###

Let's consider some real-world data. We're going to want to fetch some data from the ICGC dataset pertaining to Acute Lymphoblastic Leukemia. We're going to apply dimensionality reduction to gene expression data to see if any clustering occurs.

Please run the example in `examples/3-genomic-data`.

Exercise:

1. Calculating the correlation matrix can be expensive. Break the `structured_heatmap.png` step into two steps: one where we generate `correlation_matrix.tsv` and another that creates the plot

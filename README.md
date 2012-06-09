CorePlotBarChartExample
=======================

This simple CorePlot project shows you how to create a stacked bar chart with dates on the X axis.

You can change the code of the "generateData" function as you wish.

The structure of the data passed to CorePlot in order to generate the stacked bar chart is the following:

{
    "2012-05-01" =     {
        "Plot 1" = 8;
        "Plot 2" = 3;
        "Plot 3" = 5;
    };
    "2012-05-02" =     {
        "Plot 1" = 1;
        "Plot 2" = 5;
        "Plot 3" = 10;
    };
}

You can have as many "Plot" as you want.

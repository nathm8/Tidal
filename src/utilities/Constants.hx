package utilities;

function normalise(arr: Array<Float>): Array<Float> {
    var min = arr[0];
    var max = 0.0;
    for (n in arr) {
        min = n < min ? n : min;
        max = n > max ? n : max;
    }
    max -= min;
    var out = new Array<Float>();
    for (n in arr)
        out.push((n-min)/max);
    return out;
}
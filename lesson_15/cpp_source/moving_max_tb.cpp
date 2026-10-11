#include <cstdlib>
#include <cstdio>
#include "moving_max.h"

// Independent reference: directly scan the available input window.
static void reference_max(const int in[N_SAMPLES], int out[N_SAMPLES])
{
    for (int n = 0; n < N_SAMPLES; ++n) {
        const int first = n >= WINDOW - 1 ? n - WINDOW + 1 : 0;
        int maximum = in[first];
        for (int k = first + 1; k <= n; ++k)
            if (in[k] > maximum)
                maximum = in[k];
        out[n] = maximum;
    }
}

int main()
{
    const int CASES = 3;
    const char *names[CASES] = {"increasing", "decreasing", "random"};
    int vectors[CASES][N_SAMPLES];

    // Generate input signals for 3 data stream cases
    std::srand(12345);
    for (int n = 0; n < N_SAMPLES; ++n) {
        vectors[0][n] = n;
        vectors[1][n] = N_SAMPLES - 1 - n;
        vectors[2][n] = std::rand() % 201 - 100; // -100 ... 100
    }

    int errors = 0;
    for (int test = 0; test < CASES; ++test) {
        int actual[N_SAMPLES];
        int expected[N_SAMPLES];
        int input_copy[N_SAMPLES];
        for (int n = 0; n < N_SAMPLES; ++n) {
            actual[n] = 0;
            input_copy[n] = vectors[test][n];
        }
        reference_max(vectors[test], expected);
        moving_max(vectors[test], actual);

        int case_errors = 0;
        for (int n = 0; n < N_SAMPLES; ++n) {
            if (actual[n] != expected[n]) {
                std::printf("FAIL %s n=%d: got=%d expected=%d\n",
                            names[test], n, actual[n], expected[n]);
                ++case_errors;
            }
            if (vectors[test][n] != input_copy[n]) {
                std::printf("FAIL %s: input modified at n=%d\n", names[test], n);
                ++case_errors;
            }
        }
        errors += case_errors;
        if (case_errors == 0)
            std::printf("PASS %s\n", names[test]);
    }

    std::printf("%s: %d vectors, %d outputs, errors=%d\n",
                errors == 0 ? "PASS" : "FAIL", CASES,
                CASES * N_SAMPLES, errors);
    return errors == 0 ? 0 : 1;
}

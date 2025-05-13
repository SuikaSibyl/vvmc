<template>
  <div class="home">
    <!-- Show Monte Carlo Estimator -->
    <div ref="canvas_mc_estimator"></div>
    <!-- Show Importance Sampling Estimator -->
    <div ref="canvas_is_estimator"></div>
    <br/>
    <br/>
    <br/>
    <br/>
    <span> This is Importance Sampling estimator. </span>
      <div style="width: 550px;">
        <el-slider v-model="sample_speed" />
      </div>
      <div style="width: 550px;">
        <el-slider v-model="alpha_is" />
      </div>
    <!-- Show Difference Control Variates Estimator -->
    <div ref="canvas_dcv_estimator"></div>
    <span> This is Difference Control Variates estimator. </span>
  </div>
</template>

<script lang="js">
import { defineComponent } from 'vue';
import HelloWorld from '@/components/HelloWorld.vue'; // @ is an alias to /src
import Two from 'two.js';
// import everything from estimator.ts
import { EstimationVisualizer } from '@/scripts/estimator.js';
import { ExampleBeckmann } from '@/scripts/utils.js';

export default defineComponent({
  name: 'HomeView',
  components: {
    HelloWorld,
  },
  data() {
    return {
      sample_speed: 0,
      alpha_is: 50,
    };
  },
  // function called when the component is created
  mounted() {
    this.draw_canvas();
  },
  // functions defined
  methods: {
    onResize () {
      
    },
    draw_canvas() {
      // this.draw_canvas_0();
      this.draw_canvas_2();
      // this.draw_canvas_3();
      // this.draw_canvas_4();
      // this.draw_canvas_2();
      // this.draw_canvas_5();
    },
    draw_canvas_0() {
      const params = { width: 600, height: 400, type: Two.Types.canvas };
      const two = new Two(params).appendTo(this.$refs.canvas_mc_estimator);    
      const g = (x) => 1./Math.PI;
      const f = (x) => Math.sin(2 * Math.PI * x) * 0.4 + 0.5;
      const gSample = (N) => {
        // random N samples uniformly from [0, 1]
        const samples = [];
        for (let i = 0; i < N; i++) {
          // const r0 = Math.random();
          // if (r0 < 0.5) {
          //   samples.push(Math.random());
          // } else {
          // }
          samples.push(ExampleBeckmann.sample_g1([Math.random(),Math.random(),Math.random()]));
        }
        return samples;
      }
      const option = {
        two: two,
        f: f,
        g: g,
        numSamples: 10,
        gSample: gSample,
      };

      const viewer = new EstimationVisualizer(option);
    },
    draw_canvas_1() {
      const params = { width: 800, height: 400, type: Two.Types.canvas };
      const two = new Two(params).appendTo(this.$refs.canvas_is_estimator);    
      const g = (x) => (ExampleBeckmann.g1(x) * (this.alpha_is/100) + 1. * (1 - this.alpha_is/100));
      const f = (x) => {
        const result = ExampleBeckmann.f1(x) / g(x);
        if (isNaN(result)) {
          return 0;
        }
        return result;
      };
      const gSample = (N) => {
        // random N samples uniformly from [0, 1]
        const samples = [];
        for (let i = 0; i < N; i++) {
          const r0 = Math.random();
          if (r0 < this.alpha_is/100) {
            samples.push(ExampleBeckmann.sample_g1([Math.random(),Math.random(),Math.random()]));
          } else {
            samples.push(Math.random());
          }
        }
        return samples;
      };
      const getSpeed = () => { return this.sample_speed; }
      const option = {
        two: two,
        f: f,
        g: g,
        numSamples: 10,
        gSample: gSample,
        speed: getSpeed,
      };

      const viewer = new EstimationVisualizer(option);
    },
    draw_canvas_2() {
      const params = { width: 800, height: 400, type: Two.Types.canvas };
      const two = new Two(params).appendTo(this.$refs.canvas_is_estimator);    
      const g = (x) => {
        if(this.alpha_is == 50) {
          return 1
        }
        if(this.alpha_is < 50) {
          return ExampleBeckmann.g1(x) * (1 - this.alpha_is/50) + 1. * (this.alpha_is/50)
        } else {
          return ExampleBeckmann.g2(x) * ((this.alpha_is-50)/50) + 1. * (1 - (this.alpha_is-50)/50)
        }
      };
      const f1 = (x) => {
        const result = ExampleBeckmann.f1(x) / g(x);
        if (isNaN(result)) {
          return 0;
        }
        return result;
      };
      const f2 = (x) => {
        const result = ExampleBeckmann.f2(x) / g(x);
        if (isNaN(result)) {
          return 0;
        }
        return result;
      };
      const gSample = (N) => {
        // random N samples uniformly from [0, 1]
        const samples = [];
        for (let i = 0; i < N; i++) {
          const r0 = Math.random();
          if (r0 < this.alpha_is/100) {
            samples.push(ExampleBeckmann.sample_g1([Math.random(),Math.random(),Math.random()]));
          } else {
            samples.push(Math.random());
          }
        }
        return samples;
      };
      const getSpeed = () => { return this.sample_speed; }
      const option = {
        two: two,
        f: f1,
        f2: f2,
        g: g,
        numSamples: 10,
        gSample: gSample,
        speed: getSpeed,
      };

      const viewer = new EstimationVisualizer(option);
    },
    draw_canvas_3() {
      const params = { width: 800, height: 400, type: Two.Types.canvas };
      const two = new Two(params).appendTo(this.$refs.canvas_is_estimator);    
      const g = (x) => {
        if(this.alpha_is == 50) {
          return 1
        }
        if(this.alpha_is < 50) {
          return ExampleBeckmann.g1(x) * (1 - this.alpha_is/50) + 1. * (this.alpha_is/50)
        } else {
          return ExampleBeckmann.g2(x) * ((this.alpha_is-50)/50) + 1. * (1 - (this.alpha_is-50)/50)
        }
      };
      const f1 = (x) => {
        const result = ExampleBeckmann.f1_noisy(x) / g(x);
        if (isNaN(result)) {
          return 0;
        }
        return result;
      };
      const f2 = (x) => {
        const result = ExampleBeckmann.f1(x) / g(x) / 2;
        if (isNaN(result)) {
          return 0;
        }
        return result;
      };
      const gSample = (N) => {
        // random N samples uniformly from [0, 1]
        const samples = [];
        for (let i = 0; i < N; i++) {
          const r0 = Math.random();
          if (r0 < this.alpha_is/100) {
            samples.push(ExampleBeckmann.sample_g1([Math.random(),Math.random(),Math.random()]));
          } else {
            samples.push(Math.random());
          }
        }
        return samples;
      };
      const getSpeed = () => { return this.sample_speed; }
      const option = {
        two: two,
        f: f1,
        h1: f2,
        g: g,
        numSamples: 10,
        gSample: gSample,
        speed: getSpeed,
      };

      const viewer = new EstimationVisualizer(option);
    },
    draw_canvas_4() {
      const params = { width: 800, height: 400, type: Two.Types.canvas };
      const two = new Two(params).appendTo(this.$refs.canvas_is_estimator);    
      const g = (x) => {
        if(this.alpha_is == 50) {
          return 1
        }
        if(this.alpha_is < 50) {
          return ExampleBeckmann.g1(x) * (1 - this.alpha_is/50) + 1. * (this.alpha_is/50)
        } else {
          return ExampleBeckmann.g2(x) * ((this.alpha_is-50)/50) + 1. * (1 - (this.alpha_is-50)/50)
        }
      };
      const f1 = (x) => {
        const result = ExampleBeckmann.f1(x) / g(x);
        if (isNaN(result)) {
          return 0;
        }
        return result;
      };
      const f2 = (x) => {
        const result = ExampleBeckmann.f2(x) / g(x);
        if (isNaN(result)) {
          return 0;
        }
        return result;
      };
      const h1 = (x) => {
        const result = ExampleBeckmann.f1(x) / g(x) / 2;
        if (isNaN(result)) {
          return 0;
        }
        return result;
      };
      const h2 = (x) => {
        const result = ExampleBeckmann.f2(x) / g(x) / 2;
        if (isNaN(result)) {
          return 0;
        }
        return result;
      };
      const gSample = (N) => {
        // random N samples uniformly from [0, 1]
        const samples = [];
        for (let i = 0; i < N; i++) {
          const r0 = Math.random();
          if (r0 < this.alpha_is/100) {
            samples.push(ExampleBeckmann.sample_g1([Math.random(),Math.random(),Math.random()]));
          } else {
            samples.push(Math.random());
          }
        }
        return samples;
      };
      const getSpeed = () => { return this.sample_speed; }
      const option = {
        two: two,
        f: f1,
        f2: f2,
        h1: h1,
        h2: h2,
        g: g,
        numSamples: 10,
        gSample: gSample,
        speed: getSpeed,
      };

      const viewer = new EstimationVisualizer(option);
    },
  },
});
</script>

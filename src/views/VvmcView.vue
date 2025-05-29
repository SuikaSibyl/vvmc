<template>
  <div class="vxpg">
    <section class="hero">
      <div class="hero-body">
        <el-row justify="space-around" style="margin-bottom: -1em;">
          <el-col :xs="23" :sm="18" :md="20" :lg="14" :xl="14">

          <div class="is-max-desktop">
          <div class="columns is-centered">
            <div class="column has-text-centered">
              <h1 class="title is-1 publication-title">Vector-Valued Monte Carlo Integration Using Ratio Control Variates</h1>
              <div class="is-size-5 publication-authors">
                <!-- Paper authors -->
                <span class="author-block">
                  <a href="https://suikasibyl.github.io/" target="_blank">Haolin Lu</a><sup>1,2</sup>,&nbsp;&nbsp;</span>
                  <span class="author-block">
                    <a href="https://dvicini.github.io/" target="_blank">Delio Vicini</a><sup>3</sup>,&nbsp;&nbsp;</span>
                  <span class="author-block">
                    <a href="https://weschang.com/" target="_blank">Wesley Chang</a><sup>1</sup>,&nbsp;&nbsp;</span>
                  <span class="author-block">
                    <a href="https://cseweb.ucsd.edu/~tzli/" target="_blank">Tzu-Mao Li</a><sup>1</sup>
                  </span>
                  </div>

                    <div class="is-size-5 publication-authors">
                      <span class="author-block">
                        <t style="font-size: medium;">
                          <sup>1</sup>University of California, San Diego <br>
                          <sup>2</sup>Max Planck Institute for Informatics
                          <!-- add some space -->
                           &nbsp;&nbsp;
                          <sup>3</sup>Google Inc.<br/>
                        </t>
                        <div style="margin-top: 10px;">
                          ACM Transactions on Graphics (Proceedings of SIGGRAPH 2025)
                        </div>
                      </span>
                    </div>

                    <div class="column has-text-centered">
                      <div class="publication-links">
                          <!-- Arxiv PDF link -->
                        <span class="link-block">
                          <a href="https://SuikaSibyl.github.io/files/vvmc/paper.pdf" target="_blank" class="external-link button is-normal is-rounded is-dark">
                          <span style="position: relative; top: 2.0px;">
                          <svg class="svg-inline--fa fa-file-pdf fa-w-12" aria-hidden="true" focusable="false" data-prefix="fas" data-icon="envelope" role="img" xmlns="http://www.w3.org/2000/svg" viewBox="0 0 512 512" data-fa-i2svg="" width="18px" height="18px"><path fill="currentColor" d="M181.9 256.1c-5-16-4.9-46.9-2-46.9 8.4 0 7.6 36.9 2 46.9zm-1.7 47.2c-7.7 20.2-17.3 43.3-28.4 62.7 18.3-7 39-17.2 62.9-21.9-12.7-9.6-24.9-23.4-34.5-40.8zM86.1 428.1c0 .8 13.2-5.4 34.9-40.2-6.7 6.3-29.1 24.5-34.9 40.2zM248 160h136v328c0 13.3-10.7 24-24 24H24c-13.3 0-24-10.7-24-24V24C0 10.7 10.7 0 24 0h200v136c0 13.2 10.8 24 24 24zm-8 171.8c-20-12.2-33.3-29-42.7-53.8 4.5-18.5 11.6-46.6 6.2-64.2-4.7-29.4-42.4-26.5-47.8-6.8-5 18.3-.4 44.1 8.1 77-11.6 27.6-28.7 64.6-40.8 85.8-.1 0-.1.1-.2.1-27.1 13.9-73.6 44.5-54.5 68 5.6 6.9 16 10 21.5 10 17.9 0 35.7-18 61.1-61.8 25.8-8.5 54.1-19.1 79-23.2 21.7 11.8 47.1 19.5 64 19.5 29.2 0 31.2-32 19.7-43.4-13.9-13.6-54.3-9.7-73.6-7.2zM377 105L279 7c-4.5-4.5-10.6-7-17-7h-6v128h128v-6.1c0-6.3-2.5-12.4-7-16.9zm-74.1 255.3c4.1-2.7-2.5-11.9-42.8-9 37.1 15.8 42.8 9 42.8 9z"></path></svg><!-- <i class="fas fa-file-pdf"></i> Font Awesome fontawesome.com -->
                          </span>
                          <span>&nbsp;Paper</span>
                        </a>
                        </span>
                        &nbsp;
                        <!-- Arxiv PDF link -->
                        <span class="link-block">
                        <a href="https://SuikaSibyl.github.io/files/vvmc/supplementary.pdf" target="_blank" class="external-link button is-normal is-rounded is-dark">
                          <span style="position: relative; top: 2.0px;">
                          <svg class="svg-inline--fa fa-file-pdf fa-w-12" aria-hidden="true" focusable="false" data-prefix="fas" data-icon="envelope" role="img" xmlns="http://www.w3.org/2000/svg" viewBox="0 0 512 512" data-fa-i2svg="" width="18px" height="18px"><path fill="currentColor" d="M181.9 256.1c-5-16-4.9-46.9-2-46.9 8.4 0 7.6 36.9 2 46.9zm-1.7 47.2c-7.7 20.2-17.3 43.3-28.4 62.7 18.3-7 39-17.2 62.9-21.9-12.7-9.6-24.9-23.4-34.5-40.8zM86.1 428.1c0 .8 13.2-5.4 34.9-40.2-6.7 6.3-29.1 24.5-34.9 40.2zM248 160h136v328c0 13.3-10.7 24-24 24H24c-13.3 0-24-10.7-24-24V24C0 10.7 10.7 0 24 0h200v136c0 13.2 10.8 24 24 24zm-8 171.8c-20-12.2-33.3-29-42.7-53.8 4.5-18.5 11.6-46.6 6.2-64.2-4.7-29.4-42.4-26.5-47.8-6.8-5 18.3-.4 44.1 8.1 77-11.6 27.6-28.7 64.6-40.8 85.8-.1 0-.1.1-.2.1-27.1 13.9-73.6 44.5-54.5 68 5.6 6.9 16 10 21.5 10 17.9 0 35.7-18 61.1-61.8 25.8-8.5 54.1-19.1 79-23.2 21.7 11.8 47.1 19.5 64 19.5 29.2 0 31.2-32 19.7-43.4-13.9-13.6-54.3-9.7-73.6-7.2zM377 105L279 7c-4.5-4.5-10.6-7-17-7h-6v128h128v-6.1c0-6.3-2.5-12.4-7-16.9zm-74.1 255.3c4.1-2.7-2.5-11.9-42.8-9 37.1 15.8 42.8 9 42.8 9z"></path></svg><!-- <i class="fas fa-file-pdf"></i> Font Awesome fontawesome.com -->
                          </span>
                          <span>&nbsp;Supplementary</span>
                        </a>
                        </span>
                        &nbsp;
                      <span class="link-block">
                        <a href="https://drive.google.com/file/d/1G836JcP_mN7fxlNiJ-G185r0_8PKcYlb/view?usp=drive_link" target="_blank" class="external-link button is-normal is-rounded is-dark">
                          <span style="position: relative; top: 2.0px;">
                          <svg class="svg-inline--fa fa-file-pdf fa-w-12" aria-hidden="true" focusable="false" data-prefix="fas" data-icon="envelope" role="img" xmlns="http://www.w3.org/2000/svg" viewBox="0 0 512 512" data-fa-i2svg="" width="18px" height="18px"><path fill="#ffffff" d="M0 96C0 60.7 28.7 32 64 32H448c35.3 0 64 28.7 64 64V416c0 35.3-28.7 64-64 64H64c-35.3 0-64-28.7-64-64V96zM323.8 202.5c-4.5-6.6-11.9-10.5-19.8-10.5s-15.4 3.9-19.8 10.5l-87 127.6L170.7 297c-4.6-5.7-11.5-9-18.7-9s-14.2 3.3-18.7 9l-64 80c-5.8 7.2-6.9 17.1-2.9 25.4s12.4 13.6 21.6 13.6h96 32H424c8.9 0 17.1-4.9 21.2-12.8s3.6-17.4-1.4-24.7l-120-176zM112 192a48 48 0 1 0 0-96 48 48 0 1 0 0 96z"/></svg><!-- <i class="fas fa-file-pdf"></i> Font Awesome fontawesome.com -->
                          </span>
                        <span>&nbsp;Supplemental Images</span>
                        </a>
                      </span>
                        &nbsp;
                      <span class="link-block">
                        <a href="https://github.com/SuikaSibyl/vvmc/" target="_blank" class="external-link button is-normal is-rounded is-dark">
                        <span style="position: relative; top: 2.0px;">
                        <svg class="svg-inline--fa fa-file-pdf fa-w-12" aria-hidden="true" focusable="false" data-prefix="fas" data-icon="envelope" role="img" xmlns="http://www.w3.org/2000/svg" viewBox="0 0 512 512" data-fa-i2svg="" width="18px" height="18px"><path fill="currentColor" d="M165.9 397.4c0 2-2.3 3.6-5.2 3.6-3.3.3-5.6-1.3-5.6-3.6 0-2 2.3-3.6 5.2-3.6 3-.3 5.6 1.3 5.6 3.6zm-31.1-4.5c-.7 2 1.3 4.3 4.3 4.9 2.6 1 5.6 0 6.2-2s-1.3-4.3-4.3-5.2c-2.6-.7-5.5.3-6.2 2.3zm44.2-1.7c-2.9.7-4.9 2.6-4.6 4.9.3 2 2.9 3.3 5.9 2.6 2.9-.7 4.9-2.6 4.6-4.6-.3-1.9-3-3.2-5.9-2.9zM244.8 8C106.1 8 0 113.3 0 252c0 110.9 69.8 205.8 169.5 239.2 12.8 2.3 17.3-5.6 17.3-12.1 0-6.2-.3-40.4-.3-61.4 0 0-70 15-84.7-29.8 0 0-11.4-29.1-27.8-36.6 0 0-22.9-15.7 1.6-15.4 0 0 24.9 2 38.6 25.8 21.9 38.6 58.6 27.5 72.9 20.9 2.3-16 8.8-27.1 16-33.7-55.9-6.2-112.3-14.3-112.3-110.5 0-27.5 7.6-41.3 23.6-58.9-2.6-6.5-11.1-33.3 2.6-67.9 20.9-6.5 69 27 69 27 20-5.6 41.5-8.5 62.8-8.5s42.8 2.9 62.8 8.5c0 0 48.1-33.6 69-27 13.7 34.7 5.2 61.4 2.6 67.9 16 17.7 25.8 31.5 25.8 58.9 0 96.5-58.9 104.2-114.8 110.5 9.2 7.9 17 22.9 17 46.4 0 33.7-.3 75.4-.3 83.6 0 6.5 4.6 14.4 17.3 12.1C428.2 457.8 496 362.9 496 252 496 113.3 383.5 8 244.8 8zM97.2 352.9c-1.3 1-1 3.3.7 5.2 1.6 1.6 3.9 2.3 5.2 1 1.3-1 1-3.3-.7-5.2-1.6-1.6-3.9-2.3-5.2-1zm-10.8-8.1c-.7 1.3.3 2.9 2.3 3.9 1.6 1 3.6.7 4.3-.7.7-1.3-.3-2.9-2.3-3.9-2-.6-3.6-.3-4.3.7zm32.4 35.6c-1.6 1.3-1 4.3 1.3 6.2 2.3 2.3 5.2 2.6 6.5 1 1.3-1.3.7-4.3-1.3-6.2-2.2-2.3-5.2-2.6-6.5-1zm-11.4-14.7c-1.6 1-1.6 3.6 0 5.9 1.6 2.3 4.3 3.3 5.6 2.3 1.6-1.3 1.6-3.9 0-6.2-1.4-2.3-4-3.3-5.6-2z"/></svg><!-- <i class="fas fa-file-pdf"></i> Font Awesome fontawesome.com -->
                        </span>
                        <span>&nbsp;Code</span>
                      </a>
                     </span>
              </div>
            </div>
          </div>
        </div>
      </div>
      </el-col>
      </el-row>
    </div>
  </section>

  <el-row justify="space-around" style="margin-bottom: 5em;">
    <el-col :xs="23" :sm="21" :md="20" :lg="15" :xl="13">
      <!-- <el-image style="width: 100%" src="https://github.com/SuikaSibyl/SuikaSibyl.github.io/blob/master/vvmc/teaser.webp" :fit="fit" /> -->
      <picture>
        <source srcset="https://SuikaSibyl.github.io/files/vvmc/teaser.webp" type="image/webp">
        <source srcset="https://SuikaSibyl.github.io/files/vvmc/teaser.png" type="image/png"> 
        <img src="https://SuikaSibyl.github.io/files/vvmc/teaser.webp">
      </picture>
    </el-col>
  </el-row>

  <!-- Paper abstract -->
  <section style="background-color: #f5f5f5; padding: 5em;">
    <el-row justify="space-around" style="margin-bottom: 0em;">
      <el-col :xs="23" :sm="21" :md="20" :lg="15" :xl="14">
        <div class="columns is-centered has-text-centered">
          <div class="column is-four-fifths">
            <h2 class="title is-3">Abstract</h2>
          </div>
        </div>
      </el-col>
    </el-row>
    <el-row justify="space-around">
      <el-col :xs="23" :sm="21" :md="20" :lg="15" :xl="14">
      <el-divider></el-divider>
        <div class="content has-text-justified">
          <p style=" font-size: 1.05em;">
Variance reduction techniques are widely used for reducing the noise of Monte Carlo integration. However, these techniques are typically designed with the assumption that the integrand is scalar-valued. Recognizing that rendering and inverse rendering broadly involve vector-valued integrands, we identify the limitations of classical variance reduction methods in this context. To address this, we introduce ratio control variates, an estimator that leverages a ratio-based approach instead of the conventional difference-based control variates. Our analysis and experiments demonstrate that ratio control variables can significantly reduce the mean squared error of vector-valued integration compared to existing methods and are broadly applicable to various rendering and inverse rendering tasks.
          </p>
          </div>
      </el-col>
    </el-row>
  </section>

<el-row justify="space-around" style="margin: 5em;">
  <el-col :xs="24" :sm="23" :md="20" :lg="15" :xl="14">
    <div class="columns is-centered has-text-centered">
      <div class="column is-four-fifths">
        <h2 class="title is-3">Key Insights</h2>
      </div>
    </div>
    <el-divider></el-divider>
    <!-- canvas zero -->
    <h5 class="title is-5">Importance sampling is very helpful!</h5>
    <p style="margin-top: 1.0em; margin-bottom: 2.5em; font-size: 1.05em;">
      Monte Carlo integration estimates an integral 
      <vue-latex :expression="'\\int f(x) \\mathrm{d} x'" />, 
      by averaging the values of the 
      <b><span style="color: #3f8bbe">function <vue-latex :expression="'f'" /></span></b> at random sample points <vue-latex :expression="'X_i'" />. 
      In simple terms, we compute <vue-latex :expression="'\\frac{1}{N}\\sum_{i}{f(X_i)}'" />. 
      If <vue-latex :expression="'f'" /> is far from constant,
      the variance of this estimator can be large,
      as we are averaging values that are not close to each other.
      <br/><br/>
      <span style="color: #888888">
      <i>*
      Consider the following example, the left histogram shows the distribution of 
      the terms we are averaging, which involves a large variance.</i>
      </span>    </p>
    <div style="text-align: center; width: 100%;">
      <div ref="canvas_is_estimator"></div>
      <br/>
      <center style="padding-right: 150px;">
        <div class="slider-demo-block">
          <span class="demonstration">Sampling speed</span>
          <el-slider v-model="sample_speed_1" />
        </div>
        <div class="slider-demo-block">
          <span class="demonstration">Importance sampling</span>
          <el-slider v-model="alpha_is_1" />
        </div>
      </center>
    </div>
    <p style="margin-top: 1.0em; margin-bottom: 2.5em; font-size: 1.05em;">
      A key technique in variance reduction is importance sampling,
      which allows us to sample from a <span style="color: #888888">distribution <vue-latex :expression="'g'" /></span>,
      and then averaging the <vue-latex :expression="'\\frac{f(X_i)}{g(X_i)}'" /> instead.
      Obviously, if  <vue-latex :expression="'g'" /> becomes more proportional to <vue-latex :expression="'f'" />,
      the term we are averaging becomes more constant, and the variance of the estimator becomes smaller.
      <br/><br/>
      <span style="color: #888888">
      <i>* Try moving the "importance sampling" slider to the right. 
        As the sampling distribution becomes more proportional to <vue-latex :expression="'f'" />, 
        the values we average (f/g) become more flat, leading to lower variance.</i>
      </span>
    </p>
    <el-divider></el-divider>
    <h5 class="title is-5">... maybe not that helpful for multiple integrands?</h5>
    <p style="margin-top: 1.0em; margin-bottom: 2.5em; font-size: 1.05em;">
      While importance sampling is a powerful technique, what if we have more than one integrand,
      for example, <span style="color: #ff9130">two</span>?
    </p>
    <div style="text-align: center; width: 100%;">
      <div ref="canvas_vvis_estimator"></div>
        <center style="padding-right: 150px;">
          <div class="slider-demo-block">
            <span class="demonstration">Importance sampling</span>
            <el-slider v-model="alpha_is_2" />
            </div>
        </center>
    </div>
    <p style="margin-top: 1.0em; margin-bottom: 2.5em; font-size: 1.05em;">
      <span style="color: #888888">
      <i>*Drag the slider to left to make it more proportional to <span style="color: #3f8bbe">integrand <vue-latex :expression="'f_1'" /></span>,
        to right to make it more proportional to <span style="color: #ff9130">integrand <vue-latex :expression="'f_2'" /></span>.</i>
      </span>
      <br/><br/>
      Seems like if we tailor the sampling distribution to one of the integrands,
      the variance of the estimator for the other integrand becomes larger.
      Generally, it seems unlikely that we can find a sampling distribution
      that is proportional to all the integrands at the same time.
      Therefore, importance sampling is not that helpful for multiple (or say "vector-valued") integrands.
    </p>
    <el-divider></el-divider>
    <h5 class="title is-5">Why vector-valued integration matters?</h5>
    <p style="margin-top: 1.0em; margin-bottom: 2.5em; font-size: 1.05em;">
      But wait, why not just estimate each scalar-valued integration independently, then we can 
      use different sampling distributions for each integrand?
      Why we even care about vector-valued integration?
      <br/><br/>
      Because vector-valued integration is everywhere!
      <br/><br/>
      In forward rendering, we often approximate the radiance using three color channels (RGB).
      The rendering equation is thus a vector-valued integral, where each color channel has an integrand.
    </p>
    <center>
      <div style="width: 65%; max-width: 600px; margin: auto;">
        <picture>
          <source srcset="https://SuikaSibyl.github.io/files/vvmc/cboxrgb.webp" type="image/webp">
          <img src="https://SuikaSibyl.github.io/files/vvmc/cboxrgb.webp">
        </picture>
      </div>
    </center>
    <p style="margin-top: 1.0em; margin-bottom: 2.5em; font-size: 1.05em;">
Notice that once a path is sampled, computing either a single-channel contribution or the full RGB contribution typically incurs the same cost. 
The main expense lies in tracing the path—that is, generating a sample. 
Therefore, solving each channel independently would require tracing three times as many paths, which is inefficient.
We want each path to contribute to all three channels simultaneously, which is why we need vector-valued integration.
    </p>
    <p style="margin-top: 1.0em; margin-bottom: 2.5em; font-size: 1.05em;">
      The same is true for inverse rendering, and even general gradient-based optimization problems.
      In practice, we usually have many parameters to optimize,
      thus we need to estimate the gradient vector of all the parameters.
      Simultaneously, stochastic gradient descent (SGD) is a common optimization method,
      that samples a batch of data points to compute the gradient, which is a Monte Carlo estimate.
      Therefore, the gradient estimation is also a vector-valued integration (or summation).
    </p>
    <center>
      <div style="width: 65%; max-width: 600px; margin: auto;">
        <picture>
          <source srcset="https://SuikaSibyl.github.io/files/vvmc/backprop.webp" type="image/webp">
          <img src="https://SuikaSibyl.github.io/files/vvmc/backprop.webp">
        </picture>
        <p>* this figure comes from
          <a href="https://www.youtube.com/watch?v=aircAruvnKk" target="_blank">3Blue1Brown</a>.
        </p>
      </div>
    </center>
    <p style="margin-top: 1.0em; margin-bottom: 2.5em; font-size: 1.05em;">
      In many cases, we can compute the entire gradient vector in a single pass,
      thanks to backpropagation. Therefore, it is also a bad idea to estimate 
      each entry (partial derivative) of the gradient vector independently.
    </p>
  </el-col>
</el-row>

<!-- https://imagehost-suikasibyl-us.oss-us-west-1.aliyuncs.com/img/vxpgteaser.png -->
<section class="section" style="background-color: #f5f5f5;">
<el-row justify="space-around" style="margin-left: 5em; margin-right: 5em;">
  <el-col :xs="23" :sm="21" :md="20" :lg="15" :xl="14">
    <div class="columns is-centered has-text-centered">
      <div class="column is-four-fifths">
        <h2 class="title is-3">Our Approach</h2>
      </div>
    </div>
    <el-divider></el-divider>
    <div style="text-align: center; width: 100%;">
      <p style="text-align: left; margin-top: 1.0em; margin-bottom: 2.5em; font-size: 1.05em;">
        Will be updated soon!<br>
      </p>
    </div>
  </el-col>
</el-row>
</section>

<!--BibTex citation --> 
<section class="section" id="BibTeX" style="margin-left: 5em; margin-right: 5em;">
  <el-row justify="space-around" style="margin-bottom: 0em;">
    <el-col :xs="23" :sm="21" :md="20" :lg="15" :xl="14">
    <el-divider></el-divider>

  <pre><code> 
  TBA
<!-- @article{Lu:2024:VXPG,
  author = {Lu, Haolin and Chang, Wesley and Hedstrom, Trevor and Li, Tzu-Mao},
  title = {Real-Time Path Guiding Using Bounding Voxel Sampling},
  journal = {ACM Transactions on Graphics (Proceedings of SIGGRAPH)},
  year = {2024},
  volume = {43},
  number = {4},
  doi = {10.1145/3658203}
} -->
</code></pre>
    </el-col>
  </el-row>
</section>
<!--End BibTex citation -->

</div>
<section class="section" style="background-color: #f5f5f5;">
  <el-row justify="space-around" >
    <el-col :span="14" style="text-align: center; width: 100%;">
      This page was built using the <a href="https://github.com/eliahuhorwitz/Academic-project-page-template" target="_blank">Academic Project Page Template</a> which was adopted from the <a href="https://nerfies.github.io" target="_blank">Nerfies</a> project page.<br> This website is licensed under a <a rel="license"  href="http://creativecommons.org/licenses/by-sa/4.0/" target="_blank">Creative
          Commons Attribution-ShareAlike 4.0 International License</a>.
    </el-col>
  </el-row>
</section>


</template>
<script lang="js">
import { defineComponent } from 'vue';
import HelloWorld from '@/components/HelloWorld.vue'; // @ is an alias to /src
import Two from 'two.js';
// import everything from estimator.ts
import { EstimationVisualizer } from '@/scripts/estimator.js';
import { ExampleBeckmann } from '@/scripts/utils.js';

export default {
name: 'VXPGView',
components: {
},
data () {
  return {
    sample_speed_1: 5,
    alpha_is_1: 0,
    alpha_is_2: 50,
    two_canvas_1: null,
    viewer_canvas_1: null,
  };
},
watch: {
  slider_canvas_1(newVal) {
    this.data_canvas_1.movingPoint = newVal;
    this.draw_canvas_5();
  }
},
mounted() {
  this.loadAndConvertImage();
  // window.addEventListener('resize', this.onResize);
},
methods: {
  onResize () {
    this.draw_canvas();
  },
  loadAndConvertImage() {
    const img = new Image();
    // img.crossOrigin = 'Anonymous'; // Needed for external URLs
    img.onload = () => {
      this.spotlight_icon = img;
      this.draw_canvas();
    };
    img.src = 'https://SuikaSibyl.github.io/files/vxpg/flashlight.svg'; // Replace with your image URL
  },
  draw_canvas() {
    // this.draw_canvas_0();
    this.draw_canvas_1();
    this.draw_canvas_2();
    // this.draw_canvas_5();
  },
  draw_canvas_1() {
      const container = this.$refs.canvas_is_estimator;
      container.innerHTML = ''; // Clear previous canvas

      const params = { width: 600, height: 300, type: Two.Types.canvas };
      const two = new Two(params).appendTo(container);
      // log
      

      const g = (x) => (ExampleBeckmann.g1(x) * (this.alpha_is_1/100) + 1. * (1 - this.alpha_is_1/100));
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
          if (r0 < this.alpha_is_1/100) {
            samples.push(ExampleBeckmann.sample_g1([Math.random(),Math.random(),Math.random()]));
          } else {
            samples.push(Math.random());
          }
        }
        return samples;
      };
      const getSpeed = () => { return this.sample_speed_1; }
      const option = {
        two: two,
        f: f,
        g: g,
        numSamples: 10,
        gSample: gSample,
        speed: getSpeed,
        draw_samples: true,
      };

      this.viewer_canvas_1 = new EstimationVisualizer(option);
  },
  draw_canvas_2() {
  const container = this.$refs.canvas_vvis_estimator;
  container.innerHTML = ''; // Clear previous canvas

  const params = { width: 600, height: 250, type: Two.Types.canvas };
  const two = new Two(params).appendTo(container);
  const g = (x) => {
    if(this.alpha_is_2 == 50) {
      return 1
    }
    if(this.alpha_is_2 < 50) {
      return ExampleBeckmann.g1(x) * (1 - this.alpha_is_2/50) + 1. * (this.alpha_is_2/50)
    } else {
      return ExampleBeckmann.g2(x) * ((this.alpha_is_2-50)/50) + 1. * (1 - (this.alpha_is_2-50)/50)
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
      if (r0 < this.alpha_is_2/100) {
        samples.push(ExampleBeckmann.sample_g1([Math.random(),Math.random(),Math.random()]));
      } else {
        samples.push(Math.random());
      }
    }
    return samples;
  };
  const getSpeed = () => { return this.sample_speed_1; }
  const option = {
    two: two,
    f: f1,
    f2: f2,
    g: g,
    numSamples: 10,
    gSample: gSample,
    speed: getSpeed,
    draw_samples: false,
  };

  const viewer = new EstimationVisualizer(option);
},
}
}
</script>

<style>
@import "../assets/academic/css/index.css";
@import "../assets/academic/css/bulma-slider.min.css";
@import "../assets/academic/css/bulma.min.css";
@import "../assets/academic/css/fontawesome.all.min.css";
</style>

<style scoped>
.slider-demo-block {
  max-width: 600px;
  display: flex;
  align-items: center;
}
.slider-demo-block .el-slider {
  margin-top: 0;
  margin-left: 12px;
}
.slider-demo-block .demonstration {
  font-size: 14px;
  color: var(--el-text-color-secondary);
  line-height: 44px;
  flex: 1;
  overflow: hidden;
  text-overflow: ellipsis;
  white-space: nowrap;
  margin-bottom: 0;
}
.slider-demo-block .demonstration + .el-slider {
  flex: 0 0 70%;
}
</style>
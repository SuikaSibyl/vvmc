import { he, th } from 'element-plus/es/locales.mjs';
import Two from 'two.js';

export class Curve {
    constructor(options) {
        this.f = options.f;
        this.two = options.two;
        this.left = options.left;
        this.width = options.width;
        this.height = options.height;
        this.bottom = options.bottom;
        this.rgb = options.rgb;

        const left = options.left;
        const width = options.width;
        const height = options.height;
        const bottom = options.bottom;

        const fCurve = new Two.Path([], false, false);
        const fCurveFill = new Two.Path([], true, false);

        // initialize the curve points
        for (let x = 1e-6; x < 1.01-1e-6; x += 0.01) {
            const px = left + width * x;
            const py = bottom - height * this.f(x);
            fCurve.vertices.push(new Two.Anchor(px, py));
            fCurveFill.vertices.push(new Two.Anchor(px, py));
        }
        // shade the curve
        const rgba_08 = `rgba(${this.rgb.join(',')},0.8)`;
        const rgba_03 = `rgba(${this.rgb.join(',')},0.3)`;
        fCurve.stroke = rgba_08;
        fCurve.fill = 'transparent';
        fCurve.linewidth = 2;
        this.two.add(fCurve);
        
        // close the curve_fill shape
        fCurveFill.vertices.push(new Two.Anchor(left + width, bottom));
        fCurveFill.vertices.push(new Two.Anchor(left, bottom));
        fCurveFill.fill = rgba_03;
        fCurveFill.noStroke();
        this.two.add(fCurveFill);

        this.fCurve = fCurve;
        this.fCurveFill = fCurveFill;
    }
      
    update() {
        let i = 0;
        for (let x = 1e-6; x < 1.01-1e-6; x += 0.01) {
            const px = this.left + this.width * x;
            const py = this.bottom - this.height * this.f(x);
            this.fCurve.vertices[i].x = px;
            this.fCurve.vertices[i].y = py;
            this.fCurveFill.vertices[i].x = px;
            this.fCurveFill.vertices[i].y = py;
            i++;
        }
        this.fCurveFill.vertices[i].x = this.left + this.width;
        this.fCurveFill.vertices[i].y = this.bottom;
        i++;
        this.fCurveFill.vertices[i].x = this.left;
        this.fCurveFill.vertices[i].y = this.bottom;
        i++;
    }
};

export class Histogram {
    constructor(params) {
        this.numBins = params.numBins;
        this.two = params.two;
        this.sampleSum = 0;
        this.numSamples = 0;
        this.bins = [];
        this.binSamples = [];
        this.left = params.left;
        this.width = params.width;
        this.height = params.height;
        this.bottom = params.bottom;

        for(let i = 0; i < this.numBins; i++) {
            const bin = this.two.makeRectangle(
                this.left,
                this.bottom - this.height * i / (this.numBins - 1),
                2,
                this.height / this.numBins);
            bin.fill = 'rgba(31, 119, 180, 0.3)';
            bin.noStroke();
            this.bins.push(bin);
            this.binSamples.push(0);
        }
    }
    
    addSamples(y) {
        const bin = Math.floor((this.bottom - y) / this.height * this.numBins);
        this.binSamples[bin] ++;
        this.numSamples += 1;
        this.sampleSum += y;
    }

    clear() {
        for(let i = 0; i < this.numBins; i++) {
            var width = 5
            this.bins[i].translation.x = this.left + width/2;
            this.bins[i].width = width;
            this.binSamples[i] = 0;
        } 
        this.numSamples = 0;
    }

    update() {
        for(let i = 0; i < this.numBins; i++) {
            var width = this.binSamples[i] / this.numSamples;
            if(width > 0.3) width = 0.3;
            width *= 500;
            this.bins[i].translation.x = this.left + width/2;
            this.bins[i].width = width;
            this.binSamples[i] *= 0.95;
        } 
        this.numSamples *= 0.95;
        // // this.avgerageBin.translation.x = this.left + this.sampleSum / this.numSamples * 500;
        // this.avgerageBin.width = 100;
        // this.avgerageBin.translation.x = this.left + 50;
        // this.avgerageBin.translation.y = this.sampleSum / this.numSamples;
    }
};

export class HorizontalHistogram {
    constructor(params) {
        this.numBins = params.numBins;
        this.two = params.two;
        this.sampleSum = 0;
        this.numSamples = 0;
        this.bins = [];
        this.binSamples = [];
        this.left = params.left;
        this.width = params.width;
        this.height = params.height;
        this.bottom = params.bottom;

        const width = this.width / this.numBins;
        for(let i = 0; i < this.numBins; i++) {
            const bin = this.two.makeRectangle(
                this.left + this.width * (i + 0.5) / (this.numBins),
                this.bottom,
                this.width / this.numBins - 1.5,
                0);
            bin.fill = 'rgba(100, 100, 100, 0.2)';
            bin.noStroke();
            this.bins.push(bin);
            this.binSamples.push(0);
        }
    }
    
    addSamples(x) {
        const bin = Math.floor((x - this.left) / this.width * this.numBins);
        this.binSamples[bin] ++;
        this.numSamples += 1;
    }

    update() {
        for(let i = 0; i < this.numBins; i++) {
            const height = this.binSamples[i] * 1100 / this.numSamples;
            this.bins[i].translation.y = this.bottom - height/2;
            this.bins[i].height = height;
        }
        
        for(let i = 0; i < this.numBins; i++) {
            this.binSamples[i] *= 0.95;
        }
        this.numSamples *= 0.95;
    }
};

export class Samples {
    constructor(options) {
        this.f_curve = options.f_curve;
        this.g_curve = options.g_curve;
        this.f_hist = options.f_hist;
        this.g_hist = options.g_hist;
        this.gSample = options.gSample;
        this.two = options.two;
        this.numSamples = options.numSamples;
        this.left = options.left;

        // draw the samples
        this.samples = [];
        this.start_pos = [];
        this.target_pos = [];
        this.status = 'stage-1';
        this.alpha = 0;

        const sampleXs = this.gSample(this.numSamples);
        
        sampleXs.forEach((x) => {
            const starg_pos = [
                this.g_curve.left + this.g_curve.width * x,
                this.g_curve.bottom - this.g_curve.height * this.g_curve.f(x)
            ]
            const target_pos = [
                this.g_curve.left + this.g_curve.width * x,
                this.f_curve.bottom - this.f_curve.height * this.f_curve.f(x)
            ];
            this.start_pos.push(starg_pos);
            this.target_pos.push(target_pos);
            const circle = this.two.makeCircle(
                starg_pos[0],
                starg_pos[1],
                5);
            circle.fill = 'rgba(80, 80, 80, 0.3)';
            circle.stroke = 'rgba(80, 80, 80, 0.5)';
            this.samples.push(circle);
            this.g_hist.addSamples(starg_pos[0]);
        });
    }
    
    update(speed) {
        if (this.alpha < 1.0) {
            this.samples.forEach((sample, i) => {
                const target_pos = this.target_pos[i];
                const start_pos = this.start_pos[i];
                const pos = sample.translation;
                pos.x = target_pos[0] * this.alpha + start_pos[0] * (1 - this.alpha);
                pos.y = target_pos[1] * this.alpha + start_pos[1] * (1 - this.alpha);
                sample.translation = pos;
                sample.visible = true;
            });
            this.alpha += 0.005 * speed;
            
            if (this.alpha > 1.0 && this.status == 'stage-1') {
                this.status = 'stage-2';
                this.samples.forEach((sample, i) => {
                    this.start_pos[i] = this.target_pos[i];
                    this.target_pos[i] = [this.left, this.target_pos[i][1]];  
                    sample.fill = 'rgba(31, 119, 180, 0.3)';
                    sample.stroke = 'rgba(31, 119, 180, 0.5)';
                });
                this.alpha = 0.;
            }
        }
        else {
            this.alpha = 0.;
            this.status = 'stage-1';
            const sampleXs = this.gSample(this.numSamples);
            this.samples.forEach((sample, i) => {
                this.f_hist.addSamples(this.target_pos[i][1]);
                const x = sampleXs[i];
                const start_pos = [
                    this.g_curve.left + this.g_curve.width * x,
                    this.g_curve.bottom - this.g_curve.height * this.g_curve.f(x)
                ]
                this.g_hist.addSamples(start_pos[0]);
                const target_pos = [
                    this.g_curve.left + this.g_curve.width * x,
                    this.f_curve.bottom - this.f_curve.height * this.f_curve.f(x)
                ];
                sample.fill = 'rgba(80, 80, 80, 0.3)';
                sample.stroke = 'rgba(80, 80, 80, 0.5)';
                this.start_pos[i] = start_pos;
                this.target_pos[i] = target_pos;
            });
            this.g_hist.update()
            this.f_hist.update()
        }
    }
};

export class EstimationVisualizer {
    constructor(options) {
        this.two = options.two;
        this.g = options.g;
        this.numSamples = options.numSamples !== undefined ? options.numSamples : 10;
        this.width = this.two.width;
        this.height = this.two.height;

        this.draw_samples = options.draw_samples;

        this.f_curve = new Curve({
            f: options.f,
            two: this.two,
            left: this.width * 0.25,
            width: this.width * 0.5,
            height: this.height * 0.15,
            bottom: this.height * 0.6,
            rgb: [31, 119, 180],
        })
        
        this.g_curve = new Curve({
            f: options.g,
            two: this.two,
            left: this.width * 0.25,
            width: this.width * 0.5,
            height: this.height * 0.15,
            bottom: this.height,
            rgb: [100, 100, 100],
        })
        
        // // if options has f2:
        // if (options.f2) {
        //     this.f2_curve = new Curve({
        //         f: options.f2,
        //         two: this.two,
        //         left: this.width * 0.25,
        //         width: this.width * 0.5,
        //         height: this.height * 0.15,
        //         bottom: this.height * 0.6,
        //         rgb: [255, 127, 14],
        //     })
        // }
        if (options.h1) {
            this.h1_curve = new Curve({
                f: options.h1,
                two: this.two,
                left: this.width * 0.25,
                width: this.width * 0.5,
                height: this.height * 0.15,
                bottom: this.height * 0.6,
                rgb: [31, 119, 180],
            })
        }
        if (options.f2) {
            this.f2_curve = new Curve({
                f: options.f2,
                two: this.two,
                left: this.width * 0.25,
                width: this.width * 0.5,
                height: this.height * 0.15,
                bottom: this.height * 0.6,
                rgb: [255, 127, 14],
            })
        }
        else {
            this.f2_curve = null;
        }
        if (options.h2) {
            this.h2_curve = new Curve({
                f: options.h2,
                two: this.two,
                left: this.width * 0.25,
                width: this.width * 0.5,
                height: this.height * 0.15,
                bottom: this.height * 0.6,
                rgb: [255, 127, 14],
            })
        }

        if (this.draw_samples) {
        
            this.f_hist = new Histogram({
                numBins: 20,
                two: this.two,
                left: this.width * 0.05,
                width: this.width * 0.1,
                height: this.height * 0.6,
                bottom: this.height * 0.7,
            });
            
            this.g_hist = new HorizontalHistogram({
                numBins: 20,
                two: this.two,
                left: this.width * 0.25,
                width: this.width * 0.5,
                height: this.height * 0.15,
                bottom: this.height,
            });

            this.samples = new Samples({
                f_curve: this.f_curve,
                f2_curve: this.f2_curve,
                g_curve: this.g_curve,
                f_hist: this.f_hist,
                g_hist: this.g_hist,
                gSample: options.gSample,
                left: this.width * 0.1,
                two: this.two,
                numSamples: 10
            });
        }
        
        this.get_speed = options.speed
        this.two.bind('update', () => this.update());
    
        this.drawFunctions();
        this.two.update();
        this.two.play();
    }

    update() {
        if(this.samples) this.samples.update(this.get_speed());
        this.g_curve.update();
        this.f_curve.update();
        if(this.f2_curve) this.f2_curve.update();
    }
    
    drawFunctions() {
        // var radius = this.two.height / 3;
        // var resolution = 32;
        // var circle = new Two.Circle(0, 0, radius, resolution);
        // var blob = new Two.Path(circle.vertices);
        // blob.fill = 'blue';
        // blob.noStroke();
        
        // blob.closed = true;
        // blob.curved = true;
        // blob.automatic = true;
        
        // this.two.add(blob);
    }
}

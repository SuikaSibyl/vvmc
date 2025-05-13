
export class ExampleBeckmann {

    static generate_vectors(start = 0, end = Math.PI, N = 50) {
        const theta = Array.from({ length: N }, (_, i) => start + (i / (N - 1)) * (end - start));
        const cosTheta = theta.map(Math.cos);
        const sinTheta = cosTheta.map(ct => Math.sqrt(1 - ct ** 2));
        const v = sinTheta.map((st, i) => [st, 0, cosTheta[i]]);
        const scale = sinTheta.map(st => 2 * Math.PI * st);
        return { theta, v, scale };
    }
    
    static cos_theta(v) {
        return v[2];
    }

    static tan_theta(v) {
        const temp = 1 - v[2] ** 2;
        return Math.sqrt(temp) / v[2];
    }

    static squareToBeckmannPDF(m, alpha) {
        const temp = this.tan_theta(m) / alpha;
        const ct = this.cos_theta(m);
        const result = Math.exp(-(temp ** 2)) / (Math.PI * (alpha * ct) ** 2 * ct);
        return (ct < 1e-9) ? 0 : result;
    }

    static square_to_uniform_disk_concentric(sample) {
        const x = 2 * sample[0] - 1;
        const y = 2 * sample[1] - 1;
        const quadrant_1_or_3 = Math.abs(x) < Math.abs(y);
        const r = quadrant_1_or_3 ? y : x;
        const rp = quadrant_1_or_3 ? x : y;
        let phi = (0.25 * Math.PI * rp) / r;
        if (quadrant_1_or_3) phi = 0.5 * Math.PI - phi;
        if (x === 0 && y === 0) phi = 0;
        const s = Math.sin(phi), c = Math.cos(phi);
        return [r * c, r * s];
    }

    static square_to_beckmann(sample, alpha) {
        const p = ExampleBeckmann.square_to_uniform_disk_concentric(sample);
        const r2 = p[0] ** 2 + p[1] ** 2;
        const tanThetaMSqr = -(alpha ** 2) * Math.log(1 - r2);
        const cosThetaM = 1 / Math.sqrt(1 + tanThetaMSqr);
        const scale = Math.sqrt((1 - cosThetaM ** 2) / r2);
        return [p[0] * scale, p[1] * scale, cosThetaM];
    }

    static reconstructVFromTheta(theta) {
        const cosTheta = Math.cos(theta);
        const sinTheta = Math.sqrt(1 - cosTheta ** 2);
        const v = [sinTheta, 0, cosTheta];
        const scale = 2 * Math.PI * sinTheta;
        return { v, scale };
    }

    static f1(theta) {
        const thetaR = Math.PI / 2 - theta;
        // const { v: vR, scale: scaleR } = reconstructVFromTheta(thetaR);
        // let offset = 0.3 * Math.sin(thetaR * 4 * 10) + 0.5 * Math.sin(thetaR * 4 * 8);
        // offset = thetaR > Math.PI / 4 ? 0 : offset;
        return this.g1(theta) * 1.5;// + squareToBeckmannPDF(vR, 0.6) * scaleR * Math.PI / 2 * 0.5 + offset * 0.2;
    }

    static f1_noisy(theta) {
        const thetaR = Math.PI / 2 - theta;
        const { v: vR, scale: scaleR } = this.reconstructVFromTheta(thetaR);
        let offset = 0.3 * Math.sin(thetaR * 4 * 10) + 0.5 * Math.sin(thetaR * 4 * 8);
        offset = thetaR > Math.PI / 4 ? 0 : offset;
        return this.g1(theta) * 1.5 + this.squareToBeckmannPDF(vR, 0.6) * scaleR * Math.PI / 2 * 0.1;
    }

    static f2(theta) {
        return this.g2(theta) * 1.5;
    }

    static g1(_theta) {
        let theta = _theta;
        theta = Math.PI / 2 * theta;
        const { v, scale } = this.reconstructVFromTheta(theta);
        const thetaR = Math.PI / 2 - theta;
        const { v: vR, scale: scaleR } = this.reconstructVFromTheta(thetaR);
        const mainLobe = this.squareToBeckmannPDF(v, 0.4) * scale * Math.PI / 2;
        const sideLobe = this.squareToBeckmannPDF(vR, 0.8) * scaleR * Math.PI / 2;
        return (mainLobe * 0.6 + sideLobe * 0.4);
    }

    static g2(_theta) {
        let theta = _theta;
        theta = Math.PI / 2 * theta;
        const thetaR = theta;
        theta = Math.PI / 2 - theta;
        const { v, scale } = this.reconstructVFromTheta(theta);
        const { v: vR, scale: scaleR } = this.reconstructVFromTheta(thetaR);
        const mainLobe = this.squareToBeckmannPDF(v, 0.5) * scale * Math.PI / 2;
        const sideLobe = this.squareToBeckmannPDF(vR, 0.9) * scaleR * Math.PI / 2;
        return (mainLobe * 0.6 + sideLobe * 0.4);
    }
    
    //
    static sample_g1(sample) {
        const r0 = sample[2];
        if(r0 < 0.6) {
            return Math.acos(ExampleBeckmann.square_to_beckmann(
                [Math.random(), Math.random()], 0.4)[2]) / (Math.PI/ 2);
        }
        else {
            return 1 - (Math.acos(ExampleBeckmann.square_to_beckmann(
                [Math.random(), Math.random()], 0.8)[2]) / (Math.PI / 2));
        }
    }
};
#include "Config.as"
#include "Maths.as"
#include "Vec3f.as"
#include "Frustum.as"
#include "Interpolation.as"

shared class Camera
{
	Vec3f position;
	private Vec3f prevPosition;
	Vec3f interPosition;

	Vec3f rotation;
	private Vec3f prevRotation;
	Vec3f interRotation;

	private SColor fogColor = SColor(255, 165, 189, 200);

	private float[] modelMatrix;
	private float[] viewMatrix;
	private float[] projectionMatrix;
	private float[] rotationMatrix;

	private Frustum frustum;

	private Driver@ driver = getDriver();
	private ConfigFile@ cfg = Config::getConfig();

	Camera()
	{
		Matrix::MakeIdentity(modelMatrix);
		Matrix::MakeIdentity(viewMatrix);
		Matrix::MakeIdentity(projectionMatrix);
		Matrix::MakeIdentity(rotationMatrix);

		UpdateViewMatrix();
		UpdateRotationMatrix();
		UpdateProjectionMatrix();
		UpdateFog();
		UpdateFrustum();
	}

	void Update()
	{
		prevPosition = position;
		prevRotation = rotation;
	}

	void Render()
	{
		float t = Interpolation::getFrameTime();
		interPosition = prevPosition.lerp(position, t);
		interRotation = prevRotation.lerpAngle(rotation, t);

		UpdateViewMatrix();
		UpdateRotationMatrix();
		UpdateFrustum();

		Vec2f screenDim = driver.getScreenDimensions();
		GUI::DrawRectangle(Vec2f_zero, screenDim, fogColor);

		Render::SetTransform(modelMatrix, viewMatrix, projectionMatrix);
	}

	float getFOV()
	{
		return cfg.read_f32("fov", 70.0f);
	}

	void SetFOV(float fov)
	{
		cfg.add_f32("fov", fov);
		Config::SaveConfig(cfg);

		UpdateProjectionMatrix();
	}

	float getRenderDistance()
	{
		return cfg.read_f32("render_distance", 80.0f);
	}

	void SetRenderDistance(float distance)
	{
		cfg.add_f32("render_distance", distance);
		Config::SaveConfig(cfg);

		UpdateProjectionMatrix();
		UpdateFog();
	}

	Frustum@ getFrustum()
	{
		return frustum;
	}

	float[] getModelMatrix()
	{
		return modelMatrix;
	}

	float[] getViewMatrix()
	{
		return viewMatrix;
	}

	float[] getProjectionMatrix()
	{
		return projectionMatrix;
	}

	float[] getRotationMatrix()
	{
		return rotationMatrix;
	}

	private void UpdateProjectionMatrix()
	{
		Matrix::MakePerspective(projectionMatrix,
			Maths::toRadians(getFOV()),
			getScreenWidth() / float(getScreenHeight()),
			0.01f, getRenderDistance()
		);
	}

	private void UpdateViewMatrix()
	{
		float[] translation;
		Matrix::MakeIdentity(translation);
		Matrix::SetTranslation(translation, -interPosition.x, -interPosition.y, -interPosition.z);

		Matrix::Multiply(rotationMatrix, translation, viewMatrix);
	}

	private void UpdateRotationMatrix()
	{
		float[] tempX;
		Matrix::MakeIdentity(tempX);
		Matrix::SetRotationDegrees(tempX, interRotation.x, 0, 0);

		float[] tempY;
		Matrix::MakeIdentity(tempY);
		Matrix::SetRotationDegrees(tempY, 0, interRotation.y, 0);

		float[] tempZ;
		Matrix::MakeIdentity(tempZ);
		Matrix::SetRotationDegrees(tempZ, 0, 0, interRotation.z);

		Matrix::Multiply(tempX, tempZ, rotationMatrix);
		Matrix::Multiply(rotationMatrix, tempY, rotationMatrix);
	}

	private void UpdateFog()
	{
		float renderDistance = getRenderDistance();
		Render::SetFog(fogColor, SMesh::LINEAR, renderDistance - 10, renderDistance, 0, false, true);
	}

	private void UpdateFrustum()
	{
		float[] rotProjMatrix;
		Matrix::Multiply(projectionMatrix, rotationMatrix, rotProjMatrix);
		frustum.Update(rotProjMatrix);
	}
}

namespace Camera
{
	shared Camera@ getCamera()
	{
		Camera@ camera;
		if (!getRules().get("camera", @camera) && isClient())
		{
			@camera = Camera();
			getRules().set("camera", @camera);
		}
		return camera;
	}
}

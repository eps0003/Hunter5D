#include "Config.as"
#include "Maths.as"
#include "Vec3f.as"

shared class Camera
{
	private Vec3f position;
	private Vec3f rotation;

	private SColor fogColor = SColor(255, 165, 189, 200);

	private float[] modelMatrix;
	private float[] viewMatrix;
	private float[] projectionMatrix;
	private float[] rotationMatrix;

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
	}

	void Render()
	{
		Vec2f screenDim = driver.getScreenDimensions();
		GUI::DrawRectangle(Vec2f_zero, screenDim, fogColor);

		Render::SetTransform(modelMatrix, viewMatrix, projectionMatrix);
	}

	Vec3f position
	{
		get const
		{
			return position;
		}
		set
		{
			position = value;
			UpdateViewMatrix();
		}
	}

	Vec3f rotation
	{
		get const
		{
			return rotation;
		}
		set
		{
			rotation = value;
			UpdateRotationMatrix();
		}
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
		Matrix::SetTranslation(translation, -position.x, -position.y, -position.z);

		Matrix::Multiply(rotationMatrix, translation, viewMatrix);
	}

	private void UpdateRotationMatrix()
	{
		float[] tempX;
		Matrix::MakeIdentity(tempX);
		Matrix::SetRotationDegrees(tempX, rotation.x, 0, 0);

		float[] tempY;
		Matrix::MakeIdentity(tempY);
		Matrix::SetRotationDegrees(tempY, 0, rotation.y, 0);

		float[] tempZ;
		Matrix::MakeIdentity(tempZ);
		Matrix::SetRotationDegrees(tempZ, 0, 0, rotation.z);

		Matrix::Multiply(tempX, tempZ, rotationMatrix);
		Matrix::Multiply(rotationMatrix, tempY, rotationMatrix);
	}

	private void UpdateFog()
	{
		float renderDistance = getRenderDistance();
		Render::SetFog(fogColor, SMesh::LINEAR, renderDistance - 10, renderDistance, 0, false, true);
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
